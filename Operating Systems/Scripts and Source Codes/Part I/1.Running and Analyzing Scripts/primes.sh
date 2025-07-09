#!/bin/bash

#
# Recursively generates primes up to $LIMIT by testing each candidate n
# for divisibility by earlier primes using the “%” operator.  Includes
# extensive echo statements to show exactly how each n is tested and
# how the prime list grows.

LIMIT=5

# ----------------------------------------
# Primes FUNCTION
# ----------------------------------------
Primes() {
    local last="$1"
    shift
    # Compute next candidate
    local n=$(( last + 1 ))
    echo
    echo ">>> Primes called: last=$last, primes_so_far=($*)"
    echo "    Next candidate: n=$n"

    # Base case: reached beyond LIMIT
    if (( n > LIMIT )); then
        echo ">>> n ($n) > LIMIT ($LIMIT). Final prime list: $*"
        echo
        echo "Primes up to $LIMIT: $*"
        return
    fi

    # Test n against all known primes
    for p in "$@"; do
        local sq=$(( p * p ))
        echo "    Testing divisor p=$p (p*p=$sq)"
        if (( sq > n )); then
            echo "      Since $sq > $n, no further tests needed"
            break
        fi
        local rem=$(( n % p ))
        echo "      n % p = $rem"
        if (( rem == 0 )); then
            echo "      => $n is divisible by $p, NOT prime"
            echo "      Recurse without adding $n"
            Primes "$n" "$@"
            return
        else
            echo "      => $n is NOT divisible by $p, continue testing"
        fi
    done

    # No divisor found => n is prime
    echo "    => $n is PRIME (no divisors found)"
    echo "    Recurse adding $n to prime list"
    Primes "$n" "$@" "$n"
}

# Kick off recursion from 1 (so first n=2)
echo "Starting prime generation up to $LIMIT..."
Primes 1
exit 0
