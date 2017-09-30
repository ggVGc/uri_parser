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
  # doTest "$1" "http:///hostname.com/path?arg=value#fragment"
  # doTest "$1" "http://:12@hostname.com/path?arg=value"
  # doTest "$1" "http://:12@hostname/path?arg=value"
  # doTest "$1" "http:/hostname.com/path?arg=value#fragment"
  # doTest "$1" "//hostname.com:/path?arg=value#fragment"
  doTest "$1" "http://hostnamecom/path"
  doTest "$1" "/name:pass@hostname.com:123/path?arg=value#fragment"
  doTest "$1" "http://name:pass@hostname.com:124/path?arg=value#fragment"
  doTest "$1" "hostname.com/pa:th?arg=value#fragment"
  doTest "$1" "http://name:@hostname.com/path?arg=value#fragment"
  doTest "$1" "http://hostname.com/pat:/h?arg=value#fragment"
  doTest "$1" "http://hostname.com/pat:/h?arg=va:lue#fragment"
  doTest "$1" "hostname.com/path?arg=value#fragment"
  doTest "$1" "/hostname.com/path?arg=value#fragment"
  doTest "$1" "/hostname.com:12/path?arg=value#fragment"
  doTest "$1" "///hostname.com:12/path?arg=value#fragment"

  # doTest "$1" "http:://hostname.com/pat:/h?arg=va:lue#fragment"
}

# runTestsFor "./parse_url.py"
runTestsFor "./regex.sh"


echo "All passed!"

exit 0






