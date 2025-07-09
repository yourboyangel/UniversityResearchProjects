#!/bin/bash

echo "Please type a word:"
read word
length=$(echo -n "$word" | wc -c)
echo "The word '$word' is $length characters long."
