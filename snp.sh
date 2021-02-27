#!/bin/bash

# snp => show non-printable 
# aim: explicitly show common non-printable characters in their escaped form
# usage: bash <(curl -sL http://realrz.com/scripts/snp.sh) filename.txt

# the following mappings are supported
# 1. newline (line feed) => \n
# 2. carriage return => \r
# 3. tab => \t
# 4. space => \x20

# options: by default, all the mappings above are carried out, you can specify those mappings
# using options: -n: newline (line feed); -r: carriage return; -t: tab; -s: space
# options can be combined, e.g. -nr means only transform newline and carriage return 

# install xxd
if ! command -v xxd &>/dev/null; then
	apt update
	yes | apt install xxd &> /dev/null  
fi

# character       UTF-8 hex    Printable
# line feed       0a           no
# carriage return 0d           no
# tab             09           no
# space           20           no
# \               5c           yes
# n               6e           yes
# r               72           yes
# t               74           yes
# x               78           yes
# 2               32           yes
# 0               30           yes

# main program starts here
xxd -c 1 "$1" \
| awk '{print $2}' \
| sed 's/0a/5c6e/g' \
| sed 's/0d/5c72/g' \
| sed 's/09/5c74/g' \
| sed 's/20/5c783230/g' \
| tr -d '\n' \
| xxd -r -p
# use echo to add new line to stdout
echo
