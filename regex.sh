#!/usr/bin/env bash

read -r input

formatString="\4\n\
\2\n\
[path] => \5\n\
[query] => \7\n\
[fragment] => \9"

# Regex from reference implementation at: https://tools.ietf.org/html/rfc3986#page-50
fullResult=$(printf "%s" "$input" | sed -rn "s;^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?;$formatString;p")

scheme=$(echo "$fullResult" | sed -n '2{p;q;}') # pull 2nd line
authority=$(printf "%s" "$fullResult" | head -1)

# Translate empty port to '-1' and other empty fields to null
function sanitizeOutput() {
  while read -r entry; do
    printf "%s\n" "$entry" \
      | sed 's/^\(\[port]\) =>[[:blank:]]*$/\1 => -1/' \
      | sed 's/^\(\[.*\]\) =>[[:blank:]]*$/\1 => null/'
  done
}

echo "Map("

# Print scheme first
if [[ "$scheme" != "" ]]; then
  printf "[scheme] => %s\n" "$scheme"
else
  echo "[scheme] => null"
fi


if [[ "$authority" == "" ]]; then
  echo "[host] => null"
  echo "[port] => -1"
  echo "[user] => null"
  echo "[pass] => null"
else
  # Expand host, port and user info
  printf "%s\n" "$authority" | sed -rn "s;^\
(([^:]*):([^:^@]*)@)?\
@?\
([^:]+)\
:?([0-9]+)?.*;\
[host] => \4\n\
[port] => \5\n\
[user] => \2\n\
[pass] => \3\
;p" | sanitizeOutput
fi

# Print out the rest
printf "%s\n" "$fullResult" | tail +3 | sanitizeOutput

echo ")"


