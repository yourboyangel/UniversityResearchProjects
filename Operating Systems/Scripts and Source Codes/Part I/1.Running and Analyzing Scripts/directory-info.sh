#!/bin/bash

#
# Parses and lists directory contents, builds indices, computes checksums,
# and locates files, with extensive debug echoes at each step.
# Original script by Michael Zick; enhanced with inline comments and debug logs.

# --- Configuration & Defaults ---
SELF=$(basename "$0")
MD5UCFS=${1:-${MD5UCFS:-'/tmpfs/ucfs'}}
EXCLUDE_PATHS=(${2:-${EXCLUDE_PATHS:-'/proc /dev /devfs /tmpfs'}})
EXCLUDE_DIRS=(${3:-${EXCLUDE_DIRS:-'ucfs lost+found tmp wtmp'}})
EXCLUDE_FILES=(${3:-${EXCLUDE_FILES:-'core "Name with Spaces"'}})

echo "DEBUG: MD5UCFS directory set to: $MD5UCFS"
echo "DEBUG: EXCLUDE_PATHS = ${EXCLUDE_PATHS[*]}"
echo "DEBUG: EXCLUDE_DIRS  = ${EXCLUDE_DIRS[*]}"
echo "DEBUG: EXCLUDE_FILES = ${EXCLUDE_FILES[*]}"

# --- Function: ListDirectory ---
# Usage: ListDirectory [-of] pattern targetArrayOrFile
ListDirectory() {
  local of=0 pat="$1" target="$2"
  echo
  echo "DEBUG: ListDirectory called with pat='$pat', target='$target'"
  # Check for -of flag
  if [ "$1" = "-of" ]; then
    of=1; pat="$2"; target="$3"
    echo "DEBUG: Output-to-file mode; will write to '$target'"
  fi

  # Run ls to gather fields
  echo "DEBUG: Running ls to gather fields..."
  local T=( $(ls --inode --ignore-backups --almost-all --directory \
                 --full-time --color=none --time=status --sort=none \
                 --format=long $pat) )
  echo "DEBUG: ls returned ${#T[@]} fields"

  if [ $of -eq 0 ]; then
    # assign into array named by $target
    eval "$target=( \"\${T[@]}\" )"
    echo "DEBUG: Assigned ${#T[@]} elements into array '$target'"
  else
    # write to file
    echo "${T[@]}" > "$target"
    echo "DEBUG: Wrote ${#T[@]} fields into file '$target'"
  fi
}

# --- Function: IsNumber ---
# Usage: IsNumber value
IsNumber() {
  echo "DEBUG: IsNumber called with '$1'"
  if ! [[ "$1" =~ ^[0-9]+$ ]]; then
    echo "DEBUG: '$1' is NOT a number"
    return 1
  fi
  echo "DEBUG: '$1' is a number"
  return 0
}

# --- Function: IndexList ---
# Usage: IndexList [-if|-of] inputArrayOrFile indexArrayOrFile
IndexList() {
  local ifile=0 ofile=0 src="$1" dst="$2"
  echo
  echo "DEBUG: IndexList called with src='$src', dst='$dst'"
  # check flags
  case "$1" in
    -if) ifile=1; src="$2"; dst="$3";;
    -of) ofile=1; src="$2"; dst="$3";;
  esac

  # read LIST
  local LIST
  if [ $ifile -eq 1 ]; then
    LIST=( $(cat "$src") )
    echo "DEBUG: Read ${#LIST[@]} fields from file '$src'"
  else
    eval "LIST=( \"\${$src[@]}\" )"
    echo "DEBUG: Copied ${#LIST[@]} fields from array '$src'"
  fi

  local -a INDEX=( 0 0 )
  local Lcnt=${#LIST[@]} Lidx=0

  while (( Lidx < Lcnt )); do
    if IsNumber "${LIST[$Lidx]}"; then
      local inode=$Lidx
      # determine name field offset
      local ft="${LIST[$((Lidx+1))]:0:1}"
      local step=$(( ft=='b'||ft=='c'?12:11 ))
      local name=$(( Lidx + step ))
      # record indexes
      INDEX+=( $inode $name )
      INDEX[0]=$(( INDEX[0]+1 ))
      echo "DEBUG: Indexed line ${INDEX[0]} → inode idx=$inode, name idx=$name"
      Lidx=$(( Lidx + step ))
    else
      ((Lidx++))
    fi
  done

  if [ $ofile -eq 1 ]; then
    echo "${INDEX[@]}" > "$dst"
    echo "DEBUG: Wrote ${#INDEX[@]} index entries to file '$dst'"
  else
    eval "$dst=( \"\${INDEX[@]}\" )"
    echo "DEBUG: Assigned ${#INDEX[@]} index entries into array '$dst'"
  fi
}

# --- Function: DigestFile ---
# Usage: DigestFile [-if] inputArrayOrFile digestArray
DigestFile() {
  local ifile=0 src="$1" dst="$2"
  echo
  echo "DEBUG: DigestFile called with src='$src', dst='$dst'"
  local T1 T2
  if [ "$1" = "-if" ]; then
    ifile=1; src="$2"; dst="$3"
    T1=( $(cat "$src") )
    echo "DEBUG: Read ${#T1[@]} bytes from file '$src' for digest"
    T2=( $(echo "${T1[@]}" | md5sum -) )
  else
    eval "T1=( \"\${$src[@]}\" )"
    echo "DEBUG: Read ${#T1[@]} bytes from array '$src' for digest"
    T2=( $(md5sum "${T1[@]}") )
  fi
  echo "DEBUG: md5sum output fields: ${#T2[@]}"
  # normalize output fields
  if [[ "${T2[1]:0:1}" == "*" ]]; then
    T2+=( "${T2[1]:1}" ); T2[1]="*"
  else
    T2+=( "${T2[1]}" ); T2[1]=" "
  fi
  # assign result
  eval "$dst=( \"\${T2[@]}\" )"
  echo "DEBUG: Assigned digest array '$dst' → ${!dst[@]}"
}

# --- Function: LocateFile ---
# Usage: LocateFile [-l] [-of] filename locationArrayOrFile
LocateFile() {
  local lk=0 of=0 file="$1" dst="$2"
  echo
  echo "DEBUG: LocateFile called with file='$file', dst='$dst'"
  # parse flags (omitted for brevity)...

  # Attempt stat if available
  if command -v stat &>/dev/null; then
    echo "DEBUG: Using stat for file info"
    local LOC1=( $(stat -t "$file") )
    local LOC2=( $(stat -tf "$file") )
    local LOC=( "${LOC1[0]}" "${LOC1[@]:3:11}" "${LOC2[@]:1:2}" "${LOC2[4]}" )
  else
    echo "DEBUG: stat not found; skipping LocateFile"
    return 1
  fi

  eval "$dst=( \"\${LOC[@]}\" )"
  echo "DEBUG: Assigned location array '$dst' → ${!dst[@]}"
}

# --- Function: ListArray ---
# Usage: ListArray arrayName
ListArray() {
  local arrName="$1"
  echo
  echo "DEBUG: Listing contents of array '$arrName'"
  eval "local -a A=( \"\${${arrName}[@]}\" )"
  echo "Size of array '$arrName' = ${#A[@]}"
  for ((i=0; i<${#A[@]}; i++)); do
    echo "  [$i] ${A[i]}"
  done
}

# --- Test Harness ---
echo
echo "=== Test: ListDirectory ==="
declare -a CUR_DIR
ListDirectory "*" CUR_DIR
ListArray CUR_DIR

echo
echo "=== Test: IndexList ==="
declare -a DIR_IDX
ListDirectory "*" "/tmp/dir.tmp"
IndexList -if "/tmp/dir.tmp" DIR_IDX
ListArray DIR_IDX

echo
echo "=== Test: DigestFile ==="
declare -a DIR_DIG
DigestFile CUR_DIR DIR_DIG
echo "Digest fields:"; ListArray DIR_DIG

echo
echo "=== Test: LocateFile ==="
declare -a FILE_LOC
LocateFile "$(pwd)/$0" FILE_LOC
ListArray FILE_LOC

exit 0
