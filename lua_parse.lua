#!/usr/bin/lua5.1

local lpeg = require 'lpeg'
local P = lpeg.P
local R = lpeg.R
local S = lpeg.S
local C = lpeg.C
local V = lpeg.V
local Ct = lpeg.Ct
local match = lpeg.match

querySep = P'?'
fragmentSep = P'#'
anything = P(1)

query = querySep^-1 * C((anything - fragmentSep)^0)
fragment = fragmentSep^-1 * C(anything^0)
userOrPass = C((anything - (fragmentSep + querySep + S'@:/'))^0)
userInfo = ((userOrPass * P':' * userOrPass)^1 * #P'@')^0
authority = 
  Ct(userInfo)
  * P'@'^-1
  * C((anything - (querySep + fragmentSep))^1)


patt = Ct(authority * query * fragment)


res = match(patt, "name:pass123@www.google.com/some/path?key=val#fragment")

for k,v in ipairs(res) do
  if k == 1 then
    if #v > 0 then
      print('\tname: ', v[1])
      print('\tpass: ', v[2])
    end
  else
    print(k,v)
  end
end
