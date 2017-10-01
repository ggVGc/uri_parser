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

scheme = Ct((C((anything - S':/')^1) * C(P':'^1) * C(P'/'^1))^0)

patt = Ct(scheme * authority * query * fragment)

res = match(patt, "ha:://user:pass123@www.google.com/some/path///?key=val#fragment")

schemeRes = res[1]
userInfoRes = res[2]

if #schemeRes then
  print('scheme => '..schemeRes[1])
  --[[
  print('colons => '..schemeRes[2])
  print('slashes => '..schemeRes[3])
  --]]
else
  print('scheme => null')
end

if #userInfoRes > 0 then
  print('name => '..userInfoRes[1])
  print('pass => '..userInfoRes[2])
else
  print('name => null')
  print('pass => null')
end

print('host => '..res[3])
print('query => '..res[4])
print('fragment => '..res[5])

