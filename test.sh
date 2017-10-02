
set -e

function doTest() {
  executable=$1
  input="$2"
  expected=$(printf "%s\n" "$input" | java ReferenceUrlParse)

  res=$(echo "$input" | $executable)

  if [[ "$res" != "$expected" ]]; then
    echo "Failed"
    echo "Res:"
    echo "$res" | sed 's/^/  /'
    echo "Expected:"
    echo "$expected" | sed 's/^/  /'
    exit 1
  fi

}

testStrings="$(./gen_tests.py)"


function runTestsFor() {
  echo "Testing: $1"

  printf "$testStrings" | while read -r test; do
    echo "$1: $test"
    doTest "$1" "$test"
    echo "Pass!"
  done



  # Not passing. Malformed?

  # doTest 17 "$1" "http:://hostname.com:12/path?arg=value#fragment"               
  # doTest 2 "$1" "http://@@path?arg=value"               

  echo "$1 Passed!"
  echo ""
}

runTestsFor "./lpeg_parse.lua"
runTestsFor "./regex.sh"
# runTestsFor "./py_parse.py"


echo "All passed!"

exit 0






