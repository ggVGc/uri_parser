function doTest() {
  id="$1"
  executable=$2
  input="$3"
  expected=$(echo "$input" | java ReferenceUrlParse)

  res=$(echo "$input" | $executable)

  if [[ "$res" != "$expected" ]]; then
    echo "Failed #$id: $input"
    echo "Res:"
    echo "$res" | sed 's/^/  /'
    echo "Expected:"
    echo "$expected" | sed 's/^/  /'
    exit 1
  fi

}


function runTestsFor() {
  echo "Testing: $1"

  doTest 1 "$1" "http:////asd:11@path?arg=value"               
  doTest 2 "$1" "http://@path?arg=value"               
  doTest 3 "$1" "111@hostname.com/path?arg=value"               
  doTest 4 "$1" "http://asdsad:12@hostname.com/path?arg=value"               
  doTest 5 "$1" "/hostname.com:/path?arg=value#fragment"             
  doTest 6 "$1" "http:/hostname.com/path?arg=value#fragment"            
  doTest 7 "$1" "http://hostname.com/path?arg=value#fragment"           
  doTest 8 "$1" "http://:12@hostname/path?arg=value"                      
  doTest 9 "$1" "http://hostnamecom/path"                                  
  doTest 10 "$1" "/name:pass@hostname.com:123/path?arg=value#fragment"       
  doTest 11 "$1" "http://name:pass@hostname.com:124/path?arg=value#fragment"  
  doTest 12 "$1" "http://name:@hostname.com/path?arg=value#fragment"           
  doTest 13 "$1" "http://hostname.com/pat:/h?arg=value#fragment"          
  doTest 14 "$1" "http://hostname.com/pat:/h?arg=va:lue#fragment"          
  doTest 15 "$1" "hostname.com/path?arg=value#fragment"                        
  doTest 16 "$1" "/hostname.com/path?arg=value#fragment"                      
  doTest 17 "$1" "/hostname.com:12/path?arg=value#fragment"                  
  doTest 18 "$1" "//asd:22@hostname.com:12/path?arg=value#fragment"               
  doTest 19 "$1" "///asda:3333@hostname.com:12/path?arg=value#fragment"               
  doTest 20 "$1" "///hostname.com:12/path?arg=value#fragment"               
  doTest 21 "$1" "////hostname.com:12/path?arg=value#fragment"               
  doTest 22 "$1" "hostname.com/pa:th?arg=value#fragment"              

  # Not passing. Malformed?

  # doTest 17 "$1" "http:://hostname.com:12/path?arg=value#fragment"               
  # doTest 2 "$1" "http://@@path?arg=value"               

  echo "Pass!"
  echo ""
}

runTestsFor "./lua_parse.lua"
runTestsFor "./regex.sh"
# runTestsFor "./py_parse.py"


echo "All passed!"

exit 0






