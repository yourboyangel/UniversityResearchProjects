#!/bin/bash

# randompw_debug.sh (ver. 1.1 – Random Password Generator with debug)
#
# Generates an alphanumeric password of length $LENGTH by picking characters
# from $MATRIX at random.  Echoes each step: the raw $RANDOM, the computed
# index, the chosen character, and the accumulating password.

# Character set: digits 0–9, uppercase A–Z, lowercase a–z
MATRIX="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
LENGTH=8

echo "DEBUG: MATRIX has length ${#MATRIX}"
echo "DEBUG: Desired password length = $LENGTH"
echo
 
PASS=""
n=1

while [ "$n" -le "$LENGTH" ]; do
    # Capture a raw random value
    rand_val=$RANDOM
    # Compute index into MATRIX
    idx=$(( rand_val % ${#MATRIX} ))
    # Extract the character at that position
    char=${MATRIX:idx:1}

    echo "DEBUG: Iteration $n:"
    echo "  RANDOM      = $rand_val"
    echo "  index       = $idx"
    echo "  char chosen = '$char'"

    # Append to PASS
    PASS="$PASS$char"
    echo "DEBUG: PASS so far = '$PASS'"
    echo

    n=$(( n + 1 ))
done

echo "Final password: $PASS"
exit 0
