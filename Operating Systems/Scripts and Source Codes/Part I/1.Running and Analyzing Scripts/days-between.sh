#!/bin/bash

# days-between.sh (ver. 1.0 – “solved” version)
#
# A tutorial‐style utility that computes the number of days between two dates
# supplied as arguments.  It echoes each intermediate step, showing the raw
# input, their conversion to epoch seconds, the difference in seconds, and
# the final day count.

# === Exit codes ===
E_BADARGS=85    # Wrong number of arguments
E_DATEFAIL=86   # Date conversion failed

# === 1. Argument check ===
if [ $# -ne 2 ]; then
    echo "Usage: $(basename "$0") <date1> <date2>"
    echo "  Dates can be in any format accepted by GNU date, e.g. YYYY-MM-DD"
    exit $E_BADARGS
fi

date1="$1"
date2="$2"

echo "DEBUG: Received dates:"
echo "  date1 = '$date1'"
echo "  date2 = '$date2'"
echo

# === 2. Convert dates to epoch seconds ===
echo -n "DEBUG: Converting '$date1' to epoch seconds... "
epoch1=$(date -d "$date1" +%s 2>/dev/null) || { echo "FAILED"; exit $E_DATEFAIL; }
echo "→ $epoch1"

echo -n "DEBUG: Converting '$date2' to epoch seconds... "
epoch2=$(date -d "$date2" +%s 2>/dev/null) || { echo "FAILED"; exit $E_DATEFAIL; }
echo "→ $epoch2"
echo

# === 3. Compute absolute difference in seconds ===
if [ "$epoch2" -ge "$epoch1" ]; then
    diff_sec=$(( epoch2 - epoch1 ))
else
    diff_sec=$(( epoch1 - epoch2 ))
fi
echo "DEBUG: Difference in seconds: $diff_sec"

# === 4. Convert seconds to days ===
# There are 86400 seconds in one day.
days=$(( diff_sec / 86400 ))
echo "DEBUG: Days between dates (integer division): $days"
echo

# === 5. Final output ===
echo "$days days between $date1 and $date2"
exit 0
