#!/bin/bash

if test ! -f "names.txt"; then
    echo "Error: File 'names.txt' not found."
    exit 1
fi
if test ! -f "template.tex"; then
    echo "Error: File 'template.tex' not found."
    exit 1
fi

while IFS= read -r name; do
    if test -z "$name"; then
        continue
    fi
    sed "s/NAME/$name/g" template.tex > letter.tex
    echo "Generated letter for $name in 'letter.tex'"
done < names.txt