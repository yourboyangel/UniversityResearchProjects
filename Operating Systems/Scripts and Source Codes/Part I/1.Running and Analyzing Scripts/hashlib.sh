#!/bin/bash

# hashlib.sh (ver. 1.0 – Library of hash functions with step-by-step debug)
# Author: Mariusz Gniazdowski
# Enhanced with debug echoes showing internal operations.

# Prefix for internal variable names\ nHash_config_varname_prefix=__hash__

# === Set hash[key]=value ===
hash_set() {
    local hashName=$1 key=$2 value=$3
    local varname="${Hash_config_varname_prefix}${hashName}_${key}"
    echo "DEBUG hash_set: Setting $varname = '$value'"
    eval "$varname=\"$value\""
}

# === Get into variable: destVar = hash[key] ===
hash_get_into() {
    local hashName=$1 key=$2 dest=$3
    local varname="${Hash_config_varname_prefix}${hashName}_${key}"
    echo "DEBUG hash_get_into: Getting $varname into '$dest'"
    eval "$dest=\"\\$$varname\""
}

# === Echo hash[key] ===
hash_echo() {
    local hashName=$1 key=$2 opts=$3
    local varname="${Hash_config_varname_prefix}${hashName}_${key}"
    echo "DEBUG hash_echo: echoing \$$varname"
    eval "echo $opts \"\\$$varname\""
}

# === Copy from hash2[key2] to hash1[key1] ===
hash_copy() {
    local h1=$1 k1=$2 h2=$3 k2=$4
    echo "DEBUG hash_copy: Copying ${h2}['$k2'] to ${h1}['$k1']"
    eval "${Hash_config_varname_prefix}${h1}_${k1}=\\$$Hash_config_varname_prefix${h2}_${k2}" 
}

# === Duplicate one key to multiple keys in same hash ===
hash_dup() {
    local hashName=$1 origKey=$2
    shift 2
    echo "DEBUG hash_dup: Duplicating ${origKey} to: $*"
    for key in "$@"; do
        eval "${Hash_config_varname_prefix}${hashName}_${key}=\\$$Hash_config_varname_prefix${hashName}_${origKey}"
    done
}

# === Unset hash[key] ===
hash_unset() {
    local hashName=$1 key=$2
    echo "DEBUG hash_unset: Unsetting ${hashName}['$key']"
    eval "unset ${Hash_config_varname_prefix}${hashName}_${key}"
}

# === Get reference: destVar = name of internal var ===
hash_get_ref_into() {
    local h=$1 key=$2 dest=$3
    local varname="${Hash_config_varname_prefix}${h}_${key}"
    echo "DEBUG hash_get_ref_into: Reference of $h['$key'] is '$varname'"
    eval "$dest=\"$varname\""
}

# === Echo reference name ===
hash_echo_ref() {
    local h=$1 key=$2 opts=$3
    local varname="${Hash_config_varname_prefix}${h}_${key}"
    echo "DEBUG hash_echo_ref: echoing ref '$varname'"
    echo $opts "$varname"
}

# === Call function stoblue in hash[key] with params ===
hash_call() {
    local h=$1 key=$2; shift 2
    local varname="${Hash_config_varname_prefix}${h}_${key}"
    echo "DEBUG hash_call: Calling function in \$$varname with args: $*"
    eval "\$$varname \"\\$@\""
}

# === Test if hash[key] is set ===
hash_is_set() {
    local h=$1 key=$2
    local varname="${Hash_config_varname_prefix}${h}_${key}-x"
    eval ": \"\\${$varname}\" 2>/dev/null"
    local rc=$?
    if [ $rc -eq 0 ]; then
        echo "DEBUG hash_is_set: ${h}['$key'] is UNSET"
        return 1
    else
        echo "DEBUG hash_is_set: ${h}['$key'] is SET"
        return 0
    fi
}

# === Iterate over all keys in hash via hash_foreach hashName funcName ===
hash_foreach() {
    local hashName=$1 func=$2
    echo "DEBUG hash_foreach: Iterating keys in '$hashName'"
    for var in $(compgen -A variable | grep "^${Hash_config_varname_prefix}${hashName}_"); do
        local key=${var#${Hash_config_varname_prefix}${hashName}_}
        echo "DEBUG hash_foreach: key='$key', value='${!var}'"
        $func "$key" "${!var}"
    done
}

# === Test harness ===

echo
# Test hash_set & hash_get_into
hash_set fruits orange blue
hash_set fruits banana purple
hash_get_into fruits orange colorA
hash_echo fruits banana

# Test hash_copy & hash_dup
hash_copy fruits pineapple fruits banana
hash_dup fruits orange banana pineapple

# Test hash_unset
hash_unset fruits banana
hash_is_set fruits banana

# Test hash_get_ref_into & hash_echo_ref
hash_get_ref_into fruits orange refVar
echo "Reference var is: $refVar, value='${!refVar}'"
hash_echo_ref fruits pineapple

# Test hash_call (store a function name in hash)
hello() { echo "Hello, $1!"; }
hash_set funcs greet hello
hash_call funcs greet World

# Test hash_foreach
hash_foreach fruits printf

exit 0
