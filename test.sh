function doTest() {
  executable=$1
  input="$2"
  expected=$(echo "$input" | java ReferenceUrlParse)

  res=$(echo "$input" | $executable)

  if [[ "$res" != "$expected" ]]; then
    echo "Failed: $executable $input"
    echo "Res:"
    echo "$res" | sed 's/^/  /'
    echo "Expected:"
    echo "$expected" | sed 's/^/  /'
    exit 1
  fi

}


function runTestsFor() {
  doTest "$1" "http:/hostname.com/path?arg=value#lelefragment"

  doTest "$1" "asda:222@hostname.com/path/lele?arg=value#anchor" # this is a URN

  doTest "$1" "http://../../hostname.com/path?arg=value#anchor"

}

runTestsFor "./parse_url.py"


echo "All passed!"

exit 0






