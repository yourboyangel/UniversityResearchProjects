#!/bin/bash

#
# A tutorial‐style utility that computes the Collatz (3n+1) sequence for a given
# positive integer, echoing each step, showing whether the number is even or odd,
# and counting how many steps it takes to reach 1.

# === Exit codes ===
E_BADARGS=85    # Wrong number of arguments

# === 1. Argument check ===
if [ $# -ne 1 ]; then
    echo "Usage: $(basename "$0") <positive-integer>"
    exit $E_BADARGS
fi

# === 2. Initialize variables ===
n="$1"
step=0
echo "DEBUG: Starting Collatz sequence with n = $n"
echo

# === 3. Generate sequence until n becomes 1 ===
while [ "$n" -ne 1 ]; do
    step=$((step + 1))
    if [ $((n % 2)) -eq 0 ]; then
        next=$((n / 2))
        echo "Step $step: $n is even → next = $next"
    else
        next=$((n * 3 + 1))
        echo "Step $step: $n is odd  → next = $next"
    fi
    n="$next"
done

# === 4. Final termination step ===
step=$((step + 1))
echo "Step $step: $n (sequence terminates)"
echo
echo "Total steps: $step"
exit 0

