#!/usr/bin/lua5.1

local lpeg = require 'lpeg'
local P = lpeg.P
local R = lpeg.R
local S = lpeg.S
local C = lpeg.C
local V = lpeg.V
local Ct = lpeg.Ct
local match = lpeg.match

function emptyToNull(s)
  s = s and s or "null"
  if s == "" then
    return "null"
  else
    return s
  end
end

local querySep = P'?'
local fragmentSep = P'#'
local anything = P(1)

local query = querySep^-1 * C((anything - fragmentSep)^0)

local fragment = fragmentSep^-1 * C(anything^0)

local userOrPass = C((anything - (fragmentSep + querySep + S'@:/'))^0)

local userInfo = ((userOrPass * P':' * userOrPass)^1 * #P'@')^0

local scheme = C((anything - S':/')^0) * P'://' 

local host = C((anything - (querySep + fragmentSep + S'/:'))^1)

local port = (P':' * C(R'09'^1))^0

local path = C((anything - (querySep + fragmentSep))^0)

local authority = 
  scheme 
  * Ct(userInfo)
  * P'@'^-1
  * host
  * port

local patt = Ct(
  Ct(
    authority^1
    + (C((anything - S':/')^1) * P':')^-1
  )
  * path
  * query
  * fragment
)

local input = io.read()
local res = match(patt, input)

local userInfoRes = res[2]


print 'Map('

if #res[1] > 0 then
  print("[scheme] => "..emptyToNull(res[1][1]))
  print("[host] => "..emptyToNull(res[1][3]))
  local portRes = res[1][4]
  if not portRes or portRes == '' then
    portRes = '-1'
  end
  print("[port] => "..emptyToNull(portRes))
  local userInfoRes =  res[1][2]
  if userInfoRes then
    print("[user] => "..emptyToNull(userInfoRes[1]))
    print("[pass] => "..emptyToNull(userInfoRes[2]))
  else
    print("[user] => null")
    print("[pass] => null")
  end
else
  print("[scheme] => null")
  print("[host] => null")
  print("[port] => -1")
  print("[user] => null")
  print("[pass] => null")
end

print("[path] => "..emptyToNull(res[2]))
print("[query] => "..emptyToNull(res[3]))
print("[fragment] => "..emptyToNull(res[4]))

print ')'
