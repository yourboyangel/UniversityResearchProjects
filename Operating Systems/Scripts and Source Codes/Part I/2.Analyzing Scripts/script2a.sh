#!/bin/bash
# Define the upper limit for the loop
MAX=10000

# Output initial setup
echo "Starting script with MAX=$MAX"

# Loop from 1 to MAX-1 (9999)
for ((nr=1; nr<$MAX; nr++))
do
    # Output the current number being checked
    echo "Checking number nr=$nr"
    
    # Calculate remainder of nr divided by 5
    let "t1 = nr % 5"
    # Output the result of the modulo operation
    echo "Computed t1 = nr % 5 = $t1"
    
    # Check if t1 is not equal to 3
    echo "Checking if t1 != 3"
    if [ "$t1" -ne 3 ]
    then
        # Output that we're skipping due to first condition failure
        echo "t1 != 3, skipping to next number"
        continue
    fi
    # Output that first condition passed
    echo "t1 == 3, proceeding to next check"
    
    # Calculate remainder of nr divided by 7
    let "t2 = nr % 7"
    # Output the result of the modulo operation
    echo "Computed t2 = nr % 7 = $t2"
    
    # Check if t2 is not equal to 4
    echo "Checking if t2 != 4"
    if [ "$t2" -ne 4 ]
    then
        # Output that we're skipping due to second condition failure
        echo "t2 != 4, skipping to next number"
        continue
    fi
    # Output that second condition passed
    echo "t2 == 4, proceeding to next check"
    
    # Calculate remainder of nr divided by 9
    let "t3 = nr % 9"
    # Output the result of the modulo operation
    echo "Computed t3 = nr % 9 = $t3"
    
    # Check if t3 is not equal to 5
    echo "Checking if t3 != 5"
    if [ "$t3" -ne 5 ]
    then
        # Output that we're skipping due to third condition failure
        echo "t3 != 5, skipping to next number"
        continue
    fi
    # Output that all conditions passed
    echo "t3 == 5, all conditions satisfied"
    
    # Output that we're breaking the loop
    echo "Breaking loop as solution found"
    break
done

# Output the final number
echo "Loop ended, final Number = $nr"
# Output script termination
echo "Script terminating"
# Exit the script with success status
exit 0