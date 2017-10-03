
set -e
fastTest=true


function expect() {
  executable=$1
  input="$2"
  expected="$3"
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


function doURLTest() {
  expected=$(printf "%s\n" "$2" | java ReferenceUrlParse)
  expect "$1" "$2" "$expected"
}


if  $fastTest ; then
urlTestStrings="\
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
  //hostname.com:/path?arg=value#fragment
  ///hostname.com:/path?arg=value#fragment
  http:/hostname.com/path?arg=value#fragment
  hostname.com/path?arg=value#fragment
  http://:12@hostname/path?arg=value
  http://123user:@hostname/path?arg=value
  http://hostname/path
  http://name:pass@hostname.com:124/path?arg=value#fragment
  http://name:@hostname.com/path?arg=value#fragment
  http://hostname.com/pat:/h?arg=value#fragment
  http://hostname.com/pat:/h?arg=va:lue#fragment
  /hostname.com/path?arg=value#fragment
  /hostname.com:12/path?arg=value#fragment
  //user:22@hostname.com:12/path?arg=value#fragment
  ///user:3333@hostname.com:12/path?arg=value#fragment
  ///hostname.com:12/path?arg=value#fragment
  ////hostname.com:12/path?arg=value#fragment
  hostname.com/pa:th?arg=va__lue#fr??23agment
"
else
  urlTestStrings="$(./gen_tests.py)"
fi



function testUrlParser() {
  echo "Testing: $1"

  printf "$urlTestStrings" | while read -r test; do
    echo "$1: $test"
      doURLTest "$1" "$test"
    echo "Pass!"
  done

  echo "$1 Passed!"
  echo ""
}

function testQueryParser() {
  echo "Testing: $1"

  expect "$1" "foo=bar?foo2=bar2" "$(printf "Map(\n[foo] => bar\n[foo2] => bar2\n)")"
  expect "$1" "foo=ba11=r" "$(printf "Map(\n[foo] => ba11=r\n)")"
  expect "$1" "?foo=bar" "$(printf "Map(\n[foo] => bar\n)")"
  expect "$1" "foo=bar?" "$(printf "Map(\n[foo] => bar\n)")"
  expect "$1" "foo=bar?foo2=" "$(printf "Map(\n[foo] => bar\n[foo2] => \n)")"

  echo "$1 Passed!"
  echo ""
}

testUrlParser "./cpp_parse"
testUrlParser "./lpeg_parse.lua"
testUrlParser "./regex.sh"
testUrlParser "./py_parse.py"

testQueryParser "./query_parse.py"

echo "All passed!"

exit 0






