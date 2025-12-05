#!/usr/bin/env bash
set -e

KEY_FILE="key.bin"

prf() {
    # PRF: F_k(msg) -> hex string
    # arg1: message
    local msg="$1"

    if [ ! -f "$KEY_FILE" ]; then
        echo "Missing $KEY_FILE (run: $0 genkey)" >&2
        exit 1
    fi

    # Read key as hex (16 bytes -> 32 hex chars)
    local key_hex
    key_hex=$(xxd -p "$KEY_FILE" | tr -d '\n')

    # Hash message with SHA-256 and take first 16 bytes (32 hex chars)
    local input_hex
    if command -v sha256sum >/dev/null 2>&1; then
        input_hex=$(printf "%s" "$msg" | sha256sum | awk '{print $1}' | cut -c1-32)
    else
        input_hex=$(printf "%s" "$msg" | shasum -a 256 | awk '{print $1}' | cut -c1-32)
    fi

    # Convert hex -> raw bytes, run AES-128-ECB with key k, then back to hex
    local out_hex
    out_hex=$(printf "%s" "$input_hex" | xxd -r -p | \
        openssl enc -aes-128-ecb -K "$key_hex" -nopad -nosalt 2>/dev/null | \
        xxd -p | tr -d '\n')

    printf "%s" "$out_hex"
}

cmd_genkey() {
    # Generate a random 16-byte key and save to key.bin
    openssl rand 16 > "$KEY_FILE"
    echo "Generated 16-byte key in $KEY_FILE"
}

cmd_alice() {
    local x="$1"
    if [ -z "$x" ]; then
        echo "Usage: $0 alice <x>" >&2
        exit 1
    fi

    # Generate a 16-byte random nonce r (hex)
    local r_hex
    r_hex=$(openssl rand -hex 16)

    # Message is x || r (concatenated as strings)
    local msg="${x}${r_hex}"

    local token
    token=$(prf "$msg")

    echo "Alice output (send this to Bob):"
    echo "r      = $r_hex"
    echo "token  = $token"
}

cmd_bob() {
    local y="$1"
    local r_hex="$2"
    local token_a="$3"

    if [ -z "$y" ] || [ -z "$r_hex" ] || [ -z "$token_a" ]; then
        echo "Usage: $0 bob <y> <r> <token>" >&2
        exit 1
    fi

    local msg="${y}${r_hex}"
    local token_b
    token_b=$(prf "$msg")

    echo "Bob recomputed token_b = $token_b"
    echo "Alice's token_a        = $token_a"
    echo

    if [ "$token_b" = "$token_a" ]; then
        echo "Result: x == y (values are equal)."
    else
        echo "Result: x != y (values differ)."
    fi
}

case "$1" in
    genkey)
        cmd_genkey
        ;;
    alice)
        shift
        cmd_alice "$@"
        ;;
    bob)
        shift
        cmd_bob "$@"
        ;;
    *)
        echo "Usage: $0 {genkey|alice|bob} ..." >&2
        exit 1
        ;;
esac
