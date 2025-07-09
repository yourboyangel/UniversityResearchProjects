#!/bin/bash


# Default solved cube (54 facelets: 9W, 9G, 9R, 9B, 9O, 9Y)
DEFAULT_CUBE="WWWWWWWWWGGGRRRBBBOOOGGGRRRBBBOOOGGGRRRBBBOOOYYYYYYYYY"

# U permutation (clockwise 90° turn of up face)
U_PERM="OOOOOOGGGGGRWWWOBBYYYGGRWWWOBBYYYGGRWWWOBBYYYBBBRRRRRR"

# L permutation (clockwise 90° turn of left face)
L_PERM="WGWGWGWGWGGGRRRBBBOOOWWORRRBBBOOOWWORRRBBBOOOYYYYYYYYY"

# Function to apply a permutation to a cube state
apply_permutation() {
    local cube="$1"
    local perm="$2"
    local result=""
    result="$perm" 
    echo "$result"
}

# Function to compute public key: L^b o U^a (default_cube)
compute_public_key() {
    local a="$1"
    local b="$2"
    local cube="$DEFAULT_CUBE"
    for ((i=0; i<a%1260; i++)); do
        cube=$(apply_permutation "$cube" "$U_PERM")
    done
    for ((i=0; i<b%1260; i++)); do
        cube=$(apply_permutation "$cube" "$L_PERM")
    done
    echo "$cube"
}

# Function to compute handshake: L^b o pk o U^a (default_cube)
compute_handshake() {
    local server_pk="$1"
    local a="$2"
    local b="$3"
    local salt="$4"
    local cube="$DEFAULT_CUBE"
    for ((i=0; i<a%1260; i++)); do
        cube=$(apply_permutation "$cube" "$U_PERM")
    done
    cube=$(apply_permutation "$cube" "$server_pk")
    for ((i=0; i<b%1260; i++)); do
        cube=$(apply_permutation "$cube" "$L_PERM")
    done
    echo -n "$cube" | openssl dgst -blake2b512 -hex -macopt hexkey:"$salt" | cut -d' ' -f2
}

echo "Rubik's Cube Encryption Simulation (Google CTF 2017)"

a=42
b=17
echo "Private key: (a=$a, b=$b)"

public_key=$(compute_public_key "$a" "$b")
echo "Public key: $public_key"

server_pub="GBBRBWRWBWBBWBRYROWYRGOGYWYRRBOYOYGWGWYBOYOOROGORGYGWG"
echo "Server public key: $server_pub"

salt="882af203cb894828"
echo "Salt: $salt"

handshake=$(compute_handshake "$server_pub" "$a" "$b" "$salt")
echo "Handshake hash: $handshake"

echo "Registering user with solved cube public key: $DEFAULT_CUBE"

echo "Login handshake for server: $handshake"
