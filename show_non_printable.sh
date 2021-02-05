#!/bin/bash

# aim: explicitly show line feed as "\n", show tab as "\t"

# usage: bash <(curl -sL http://realrz.com/scripts/show_non_printable.sh) filename.txt

# workflow: 
# 1. tranform binary text file to hex
# 2. replace line feed's hex(0a) to 5c6e, 5c is hex for "\", 6e is hex for "n"
# 3. replace tab's hex(09) to 5c74, 5c is hex for "\", 74 is hex for "t"
# 4. transform hex to binary again

# install xxd to do convertion between hex and ascii
yes Y | apt install xxd &> /dev/null  

# main program starts here
xxd -c 1 "$1" \
| awk '{print $2}' \
| sed 's/0a/5c6e/g' \
| sed 's/09/5c74/g' \
| tr -d '\n' \
| xxd -r -p
# use echo to add new line to stdout
echo
