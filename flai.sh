#!/bin/bash

# flai => find line and insert
# usage: bash <(curl -L https://raw.githubusercontent.com/librz/shell_scripts/main/flai.sh) /path/to/file "text to search"  "first line\nsecond line"

result=""
found=false

while IFS= read -r line
do
  if [[ $found = true ]]; then
    result="$result\n$line"
  else 
    if echo "$line" | grep "$2" > /dev/null 2>&1; then
      result="$result\n$line\n$3"
      found=true
    else
      result="$result\n$line"
    fi  
  fi  
done < "$1"

if [[ $found = false ]]; then
  echo "not found"
  exit 1
fi

echo -e "$result" > "$1"
