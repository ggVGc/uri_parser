
read input

formatString="\4\n\
\2\n\
[path] => \5\n\
[query] => \7\n\
[fragment] => \9"

# Regex from reference implementation at: https://tools.ietf.org/html/rfc3986#page-50
fullResult=$(printf "$input" | sed -rn "s;^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?;$formatString;p")

scheme=$(echo "$fullResult" | tail +2 | head -1)
authority=$(printf "$fullResult" | head -1)

# Translate empty port to '-1' and other empty fields to null
function sanitizeOutput() {
  while read entry; do
    printf "$entry\n" \
      | sed 's/^\(\[port]\) =>[[:blank:]]*$/\1 => -1/' \
      | sed 's/^\(\[.*\]\) =>[[:blank:]]*$/\1 => null/'
  done
}

echo "Map("

# Print scheme first
if [[ "$scheme" != "" ]]; then
  printf "[scheme] => $scheme\n"
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
  printf "$authority\n" | sed -rn "s;^\
(([^:]*):([^:^@]*)@)?\
([^:]+)\
:?([0-9]+)?.*;\
[host] => \4\n\
[port] => \5\n\
[user] => \2\n\
[pass] => \3\
  ;p" \
  |  sanitizeOutput
fi

# Print out the rest
printf "$fullResult\n" | tail +3 | sanitizeOutput

echo ")"


