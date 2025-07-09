#!/bin/bash

# string_debug.sh (ver. 1.0 – tutorial‐style string functions with debug)
#
# Bash emulation of selected C string(3) routines, with debug echoes
# showing intermediate values and results.

# === strcat: append s2 onto s1 ===
strcat() {
  local var1=$1 var2=$2
  local val1=${!var1} val2=${!var2}
  echo "DEBUG strcat: before → $var1='$val1', $var2='$val2'"
  eval "$var1"="'${val1}${val2}'"
  echo "DEBUG strcat: after  → $var1='${!var1}'"
}

# === strncat: append up to n chars of s2 onto s1 ===
strncat() {
  local var1=$1 var2=$2 n=$3
  local val1=${!var1} val2=${!var2}
  echo "DEBUG strncat: before → $var1='$val1', $var2='$val2', n=$n"
  local part=${val2:0:n}
  echo "DEBUG strncat: using substring → '$part'"
  eval "$var1"="'${val1}${part}'"
  echo "DEBUG strncat: after  → $var1='${!var1}'"
}

# === strcmp: lex compare s1 vs s2; returns -1,0,1 ===
strcmp() {
  local s1=$1 s2=$2
  echo "DEBUG strcmp: comparing '$s1' to '$s2'"
  if [[ "$s1" == "$s2" ]]; then
    echo "DEBUG strcmp: equal"
    return 0
  elif [[ "$s1" < "$s2" ]]; then
    echo "DEBUG strcmp: '$s1' < '$s2'"
    return 255  # bash returns 0-255; use 255 for -1
  else
    echo "DEBUG strcmp: '$s1' > '$s2'"
    return 1
  fi
}

# === strncmp: compare up to n chars ===
strncmp() {
  local s1=$1 s2=$2 n=$3
  echo "DEBUG strncmp: comparing first $n chars of '$s1' and '$s2'"
  local t1=${s1:0:n} t2=${s2:0:n}
  echo "DEBUG strncmp: truncated to '$t1' vs '$t2'"
  strcmp "$t1" "$t2"
  return $?
}

# === strlen: length of variable s ===
strlen() {
  local var=$1 val=${!var}
  local len=${#val}
  echo "DEBUG strlen: '$var'='$val' length=$len"
  echo "$len"
}

# === strspn: span of initial chars in s1 from set s2 ===
strspn() {
  local s1=$1 s2=$2
  echo "DEBUG strspn: s1='$s1', s2='$s2'"
  local IFS= result="${s1%%[!${s2}]*}"
  local len=${#result}
  echo "DEBUG strspn: initial span='$result' length=$len"
  echo "$len"
}

# === strcspn: initial span of chars NOT in set s2 ===
strcspn() {
  local s1=$1 s2=$2
  echo "DEBUG strcspn: s1='$s1', s2='$s2'"
  local IFS= result="${s1%%[${s2}]*}"
  local len=${#result}
  echo "DEBUG strcspn: span without chars='$result' length=$len"
  echo "$len"
}

# === strstr: substring from first occurrence of s2 in s1 ===
strstr() {
  local hay=$1 needle=$2
  echo "DEBUG strstr: haystack='$hay', needle='$needle'"
  if [ -z "$needle" ]; then
    echo "DEBUG strstr: empty needle, returning whole string"
    echo "$hay"; return 0
  fi
  case "$hay" in
    *"$needle"*)
      local prefix=${hay%%"$needle"*}
      local result=${hay#"$prefix"}
      echo "DEBUG strstr: found, returning '$result'"
      echo "$result"
      ;;
    *)
      echo "DEBUG strstr: not found, returning empty"
      return 1
      ;;
  esac
}

# === strtrunc: echo first n characters of each argument ===
strtrunc() {
  local n=$1; shift
  echo "DEBUG strtrunc: n=$n"
  for s in "$@"; do
    local part=${s:0:n}
    echo "DEBUG strtrunc: input='$s' -> '$part'"
    echo "$part"
  done
}

# === Test harness ===
echo
echo "=== Testing strcat ==="
a="foo"; b="bar"
echo "Initial: a='$a', b='$b'"
strcat a b
echo "Result: a='$a'"

echo
echo "=== Testing strncat ==="
a="foo"; b="barbaz"; n=3
echo "Initial: a='$a', b='$b', n=$n"
strncat a b "$n"
echo "Result: a='$a'"

echo
echo "=== Testing strcmp ==="
strcmp "abc" "abd"; rc=$?
echo "Return code (0=equal,255=<,1=>): $rc"
strcmp "foo" "foo"; rc=$?
echo "Return code: $rc"

echo
echo "=== Testing strncmp ==="
strncmp "abcdef" "abcxyz" 3; rc=$?
echo "Return code: $rc"
strncmp "abcdef" "abcxyz" 4; rc=$?
echo "Return code: $rc"

echo
echo "=== Testing strlen ==="
s="epoka university"
echo "Input: '$s'"
strlen s

echo
echo "=== Testing strspn ==="
strspn "123abc456789" "1230123456789"

echo
echo "=== Testing strcspn ==="
strcspn "123abc456" "0123456789"

echo
echo "=== Testing strstr ==="
strstr "Operating" "bar"
strstr "Systems" "xyz"

echo
echo "=== Testing strtrunc ==="
strtrunc 4 "abcdefghcvb" "123456789345"

exit 0
