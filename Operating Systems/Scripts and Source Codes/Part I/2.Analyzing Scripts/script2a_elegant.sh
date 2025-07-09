#!/bin/bash
# Define loop upper limit
MAX=10000

# Loop from 1 to MAX-1
for ((nr=1; nr<MAX; nr++))
do
    # Check if nr % 5 == 3, nr % 7 == 4, and nr % 9 == 5
    (( nr % 5 == 3 )) && (( nr % 7 == 4 )) && (( nr % 9 == 5 )) || continue
    # Output remainders for debugging
    echo "nr=$nr, nr%5=$(($nr % 5)), nr%7=$(($nr % 7)), nr%9=$(($nr % 9))"
    # Exit loop when conditions are met
    break
done

# Output the result
echo "Number = $nr"
exit 0
