
read input

formatString="\4\n\
\2\n\
[path] => \5\n\
[query] => \7\n\
[fragment] => \9"

# Regex from reference implementation at: https://tools.ietf.org/html/rfc3986#page-50
fullResult=$(echo "$input" | sed -rn "s;^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?;$formatString;p")

echo "Map("
# Print scheme first
scheme=$(echo "$fullResult" | tail +2 | head -1)

if [[ "$scheme" == "" ]]; then
  echo "[scheme] => null"
  echo "[host] => null"
  echo "[port] => -1"
  echo "[user] => null"
  echo "[pass] => null"
else
  echo "[scheme] => $scheme"
  # Expand host, port and user info
  echo "$fullResult" | head -1 | sed -rn "s;^\
(([^:]+):([^:^@]*)@)?\
([^:]+)\
:?([0-9]+)?.*;\
[host] => \4\n\
[port] => \5\n\
[user] => \2\n\
[pass] => \3\
  ;p" \
  | while read x
  do
    key=$(echo "$x" | sed -rn "s;(\[.*\]) =>.*;\1;p")
    value=$(echo "$x" | sed -rn "s;\[.*\] =>(.*).*;\1;p")
    if [[ "$value" == "" ]]; then
      if [[ "$key" == "[port]" ]]; then
        echo "$key => -1"
      else
        echo "$key => null"
      fi
    else
      echo "$key =>$value"
    fi
  done
fi

echo "$fullResult" | tail +3 \
  | while read x
  do
    key=$(echo "$x" | sed -rn "s;(\[.*\] =>).*;\1;p")
    value=$(echo "$x" | sed -rn "s;\[.*\] =>(.*).*;\1;p")
    if [[ "$value" == "" ]]; then
      echo "$key null"
    else
      echo "$key$value"
    fi
  done

# echo "$headEntries" \
#   | awk '\
#     NR == 1 { printf("[scheme] => "); if($0 == ""){print("null")}else{print $0} } \
#   '

echo ")"


