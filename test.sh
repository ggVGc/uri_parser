
set -e
fastTest=true

function doTest() {
  executable=$1
  input="$2"
  expected=$(printf "%s\n" "$input" | java ReferenceUrlParse)

  res=$(echo "$input" | $executable)

  if [[ "$res" != "$expected" ]]; then
    echo "Failed"
    echo ""
    echo "Res:"
    printf "%s\n" "$res" | sed 's/^/  /'
    echo ""
    echo "Expected:"
    echo "$expected" | sed 's/^/  /'
    exit 1
  fi

}


if  $fastTest ; then
testStrings="\
  http://:pass@hostname.com:123
  http://hostname.com/path?arg=value#fragment
  http://hostname
  http://hostname.com
  http://hostname.com:123
  http://user:pass@hostname.com
  http://user:@hostname.com:123
  http://user:@hostname.com
  http://:pass@hostname.com
  http://:@ho123stname.com:123
  http:////asd:11@path?arg=value
  http://user:12@hostname.com/path?arg=value
  /hostname.com:/path?arg=value#fragment
  http:/hostname.com/path?arg=value#fragment
  hostname.com/path?arg=value#fragment
  http://:12@hostname/path?arg=value
  http://hostname/path
  http://name:pass@hostname.com:124/path?arg=value#fragment
  http://name:@hostname.com/path?arg=value#fragment
  http://hostname.com/pat:/h?arg=value#fragment
  http://hostname.com/pat:/h?arg=va:lue#fragment
  /hostname.com/path?arg=value#fragment
  /hostname.com:12/path?arg=value#fragment
  //asd:22@hostname.com:12/path?arg=value#fragment
  ///asda:3333@hostname.com:12/path?arg=value#fragment
  ///hostname.com:12/path?arg=value#fragment
  ////hostname.com:12/path?arg=value#fragment
  hostname.com/pa:th?arg=value#fragment

"
  # /name:pass@hostname.com:123/path?arg=value#fragment
  # http://@path?arg=value
  # 111@hostname.com/path?arg=value

  # Not passing. Malformed?

  # doTest 17 "$1" "http:://hostname.com:12/path?arg=value#fragment"               
  # doTest 2 "$1" "http://@@path?arg=value"               
else
  testStrings="$(./gen_tests.py)"
fi



function runTestsFor() {
  echo "Testing: $1"

  printf "$testStrings" | while read -r test; do
    echo "$1: $test"
    doTest "$1" "$test"
    echo "Pass!"
  done

  echo "$1 Passed!"
  echo ""
}



runTestsFor "./cpp_parse"
# runTestsFor "./lpeg_parse.lua"
# runTestsFor "./regex.sh"
# runTestsFor "./py_parse.py"



echo "All passed!"

exit 0






