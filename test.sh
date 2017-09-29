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
  doTest "$1" "http://hostname.com/path?arg=value#fragment"
  doTest "$1" "http://name:pass@hostname.com/path?arg=value#fragment"
  doTest "$1" "http://name:@hostname.com/path?arg=value#fragment"
  doTest "$1" "http://:12@hostname.com/path?arg=value"
  doTest "$1" "http://hostname.com:123/path?arg=value#fragment"
  doTest "$1" "http://hostname.com/pat:/h?arg=value#fragment"
  doTest "$1" "http:/hostname.com/path?arg=value#fragment"
  doTest "$1" "/hostname.com/path?arg=value#fragment"
  doTest "$1" "/hostname.com:12/path?arg=value#fragment"
  doTest "$1" "//hostname.com:12/path?arg=value#fragment"

  # doTest "$1" "asda:222@hostname.com/path/lele?arg=value#anchor" # this is a URN
  #
  # doTest "$1" "http://../../hostname.com/path?arg=value#anchor"

}

runTestsFor "./parse_url.py"


echo "All passed!"

exit 0






