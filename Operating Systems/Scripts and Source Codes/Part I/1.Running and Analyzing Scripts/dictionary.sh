#!/bin/bash

#
# A tutorial‐style utility demonstrating Bash associative arrays to build
# and query a simple dictionary from a terms file.  It echoes each step:
# checking inputs, loading entries, and performing lookups.

# === Exit codes ===
E_BADARGS=85    # Incorrect usage
E_NOFILE=86     # Dictionary file not found
E_NOTERM=87     # Queried term not found

# === usage(): Show help and exit ===
usage() {
    cat << USAGE
Usage: $(basename "$0") [--help] <dict-file> [term]
Builds a simple dictionary from <dict-file>, which must contain one
"term:definition" pair per line.  If [term] is provided, prints its
definition; otherwise lists all available terms.

Options:
  --help    Show this help message and exit.

Example:
  $(basename "$0") words.txt apple
USAGE
    exit $E_BADARGS
}

# === 1. Handle --help flag ===
if [[ "$1" == "--help" ]]; then
    usage
fi

# === 2. Validate arguments ===
if [[ $# -lt 1 || $# -gt 2 ]]; then
    echo "ERROR: Wrong number of arguments."
    usage
fi

dict_file="$1"
query_term="$2"

echo "DEBUG: Dictionary file = '$dict_file'"
[[ -n "$query_term" ]] && echo "DEBUG: Query term      = '$query_term'"
echo

# === 3. Check dictionary file exists and is readable ===
if [[ ! -r "$dict_file" ]]; then
    echo "ERROR: Cannot read dictionary file '$dict_file'."
    exit $E_NOFILE
fi
echo "DEBUG: Loading entries from '$dict_file'..."

# === 4. Declare associative array and load entries ===
declare -A dict
while IFS=: read -r term definition; do
    # Skip empty lines or lines without colon
    [[ -z "$term" || -z "$definition" ]] && continue
    # Trim whitespace around term and definition
    term="${term##*( )}"         # remove leading spaces
    term="${term%%*( )}"         # remove trailing spaces
    definition="${definition##*( )}"
    definition="${definition%%*( )}"
    # Load into associative array
    dict["$term"]="$definition"
    echo "  Loaded: '$term' → '${dict[$term]}'"
done < "$dict_file"
echo "DEBUG: Total entries loaded: ${#dict[@]}"
echo

# === 5. If a term was provided, look it up; else list all terms ===
if [[ -n "$query_term" ]]; then
    echo -n "DEBUG: Looking up term '$query_term'... "
    if [[ -n "${dict[$query_term]}" ]]; then
        echo "FOUND"
        echo
        echo "Definition of '$query_term':"
        echo "  ${dict[$query_term]}"
    else
        echo "NOT FOUND"
        echo "ERROR: Term '$query_term' not in dictionary."
        exit $E_NOTERM
    fi
else
    # No query term: list all keys
    echo "Available terms (${#dict[@]}):"
    for key in "${!dict[@]}"; do
        echo "  - $key"
    done
fi

exit 0