#!/bin/bash

#
# Conway's "Game of Life" on a rectangular grid, with extensive debug
# echoes and comments to show each step: loading the initial state,
# computing neighbors, applying birth/survival rules, and displaying each
# generation.

# === Exit codes ===
E_NOSTARTFILE=86   # Missing or unreadable start file

# === Default parameters & startfile check ===
startfile="gen0"       # Default startup file
if [ -n "$1" ]; then
    startfile="$1"
fi

echo "DEBUG: Using startfile: '$startfile'"
if [ ! -e "$startfile" ]; then
    echo "ERROR: Startfile '$startfile' missing!"
    exit $E_NOSTARTFILE
fi

echo "DEBUG: Loading generation 0 from '$startfile'"
# Remove comments and join into one space-separated list
initial=( $(sed -e '/^#/d' -e '/^[[:space:]]*$/d' "$startfile" | tr -d '\n' | sed -e 's/\./\. /g' -e 's/_/_ /g') )

# === Grid parameters ===
ROWS=10           # Number of rows in the grid
COLS=10           # Number of columns in the grid
echo "DEBUG: Grid size: ${ROWS}x${COLS} (rows x cols)"

cells=$((ROWS * COLS))
echo "DEBUG: Total cell count: $cells"

# === Game rules ===
SURVIVE=2            # Living cell survives with 2 or 3 neighbors
BIRTH=3              # Dead cell becomes alive with exactly 3 neighbors
DELAY=0.5              # Seconds pause between generations
GENERATIONS=10       # Total generations to simulate

echo "DEBUG: Simulating $GENERATIONS generations with $DELAY-second delay"

# === Display function ===
# Convert array to visual grid, count alive cells
display() {
    local arr=( $1 )
    local alive=0
    echo
    for ((i=0; i<${#arr[@]}; i++)); do
        # Newline at each row start
        if (( i % COLS == 0 )); then
            echo    # newline
            echo -n "    "
        fi
        cell="${arr[i]}"
        # Count live cells
        [[ "$cell" == "." ]] && (( alive++ ))
        # Print: '.' as '•', '_' as space
        if [[ "$cell" == "." ]]; then
            echo -n "•"
        else
            echo -n " "
        fi
    done
    echo
    echo "DEBUG: Alive cells this generation: $alive"
}

# === Check valid index within grid ===
IsValid() {
    local idx=$1 row=$2
    # Global grid indices 0 .. cells-1
    if (( idx < 0 || idx >= cells )); then
        return 1
    fi
    # Check same row
    local start=$(( row * COLS ))
    local end=$(( start + COLS - 1 ))
    (( idx < start || idx > end )) && return 1
    return 0
}

# === Count living neighbors for cell idx ===
GetCount() {
    local data=( $1 ) idx=$2
    local row=$(( idx / COLS ))
    local top=$(( idx - COLS - 1 ))
    local center=$(( idx - 1 ))
    local bottom=$(( idx + COLS - 1 ))
    local count=0
    # Check 3x3 neighborhood
    for delta_row in -1 0 1; do
        for delta_col in -1 0 1; do
            # Skip the cell itself
            if (( delta_row == 0 && delta_col == 0 )); then
                continue
            fi
            local nb_idx=$(( idx + delta_row*COLS + delta_col ))
            # Validate neighbor index
            IsValid $nb_idx $row && {
                [[ "${data[nb_idx]}" == "." ]] && (( count++ ))
            }
        done
    done
    return $count
}

# === Determine if cell will be alive next gen ===
IsAlive() {
    local data_str="$1" idx=$2 current="${3}"
    GetCount "$data_str" $idx
    local neigh=$?
    echo "DEBUG: Cell $idx ('$current') has $neigh neighbors"
    if [[ "$current" == "." ]]; then
        # Survival
        (( neigh == SURVIVE || neigh == SURVIVE+1 )) && return 0
    else
        # Birth
        (( neigh == BIRTH )) && return 0
    fi
    return 1
}

# === Compute next generation and display ===
next_gen() {
    local data_str="$1"
    local old=( $data_str )
    local new=()
    for ((i=0; i<cells; i++)); do
        IsAlive "$data_str" $i "${old[i]}"
        if (( $? == 0 )); then
            new[i]='.'
        else
            new[i]='_'
        fi
    done
    # Convert back to string and display
    local new_str="${new[@]}"
    display "$new_str"
    echo "DEBUG: Completed generation $generation"
}

# === Main simulation ===
generation=0
# Display initial state
echo "=== Generation $generation ==="
display "${initial[@]}"
sleep $DELAY

# Iterate subsequent generations
while (( generation < GENERATIONS )); do
    (( generation++ ))
    echo "=== Generation $generation ==="
    next_gen "${initial[@]}"
    # Prepare for next iteration
    initial=( $(next_gen "${initial[@]}") )
    sleep $DELAY
    # Break early if no cells alive
    # (Check last display's alive count? omitted for brevity)
done

echo
echo "DEBUG: Simulation complete after $GENERATIONS generations"
exit 0
