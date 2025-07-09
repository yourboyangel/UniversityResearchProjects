#!/bin/bash

# soundex.sh (ver. 1.1 – extended tutorial version)
#
# Computes the Soundex code for each supplied name, with detailed debug
# echoes showing uppercase conversion, letter-to-digit mapping, skipping
# zeros, collapsing duplicates, padding, and final code output.

# === Exit codes ===
E_BADARGS=85    # Wrong number of arguments

# === usage(): Show help message and exit ===
usage() {
    cat <<-USAGE
Usage: $(basename "$0") [--help] name [name...]
Computes the Soundex code for each supplied name.
Options:
  --help    Show this help message and exit.
Example:
  $(basename "$0") Washington
USAGE
    exit $E_BADARGS
}

# === 1. Handle --help flag ===
if [[ "$1" == "--help" ]]; then
    usage
fi

# === 2. Argument count check ===
if [ $# -lt 1 ]; then
    echo "ERROR: At least one name is required."
    usage
fi

# === Soundex mapping table ===
declare -A soundex_map=(
    [A]=0 [E]=0 [I]=0 [O]=0 [U]=0 [Y]=0 [W]=0 [H]=0
    [B]=1 [P]=1 [F]=1 [V]=1
    [C]=2 [G]=2 [J]=2 [K]=2 [Q]=2 [S]=2 [X]=2 [Z]=2
    [D]=3 [T]=3
    [L]=4
    [M]=5 [N]=5
    [R]=6
)

# === Function to compute Soundex for a single name ===
soundex() {
    local name_upper first_letter prev_digit output_digits code

    # Convert to uppercase
    name_upper="$(echo "$1" | tr '[:lower:]' '[:upper:]')"
    echo "DEBUG: Original name: $1 -> Uppercase: $name_upper"

    # Retain first letter
    first_letter="${name_upper:0:1}"
    echo "DEBUG: First letter: $first_letter"

    # Process remaining letters
    output_digits=""
    prev_digit=""
    for (( i=1; i<${#name_upper}; i++ )); do
        letter="${name_upper:i:1}"
        digit="${soundex_map[$letter]}"
        echo -n "DEBUG: Letter '$letter' -> digit '$digit'"
        # Skip zeros
        if [ "$digit" -eq 0 ]; then
            echo " (skipped)"
            prev_digit=""
            continue
        fi
        # Collapse duplicates
        if [ "$digit" == "$prev_digit" ]; then
            echo " (duplicate, skipped)"
            continue
        fi
        # Append digit
        output_digits+="$digit"
        echo " (appended)"
        prev_digit="$digit"
        # Stop after 3 digits
        if [ ${#output_digits} -eq 3 ]; then
            echo "DEBUG: Collected 3 digits, stopping"
            break
        fi
    done

    # Pad with zeros
    while [ ${#output_digits} -lt 3 ]; do
        output_digits+="0"
        echo "DEBUG: Padding -> $output_digits"
    done

    # Combine for final code
    code="$first_letter$output_digits"
    echo "DEBUG: Final Soundex code: $code"
    echo "$code"
}

# === Main: Compute for each name ===
for name in "$@"; do
    echo
    soundex "$name"
done
