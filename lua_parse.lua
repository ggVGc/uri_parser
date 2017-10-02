#!/usr/bin/lua5.1

local lpeg = require 'lpeg'
local P = lpeg.P
local R = lpeg.R
local S = lpeg.S
local C = lpeg.C
local V = lpeg.V
local Ct = lpeg.Ct
local Cg = lpeg.Cg
local match = lpeg.match

function emptyToNull(s)
  s = s and s or "null"
  if s == "" then
    return "null"
  else
    return s
  end
end

function split(s, chars)
  local ret = {}
  for x in string.gmatch(s, '[^'..chars..']+') do
    table.insert(ret, x)
  end
  return unpack(ret)
end

local any = P(1)
local digit = R'09'

local userPassContent = (any - S'@:/')^0

local userInfo =
  (
    Cg(userPassContent, 'user')
    * P':'
    * Cg(userPassContent, 'pass')
  )^1
  * P'@'

local scheme = Cg((any - S':/')^1, 'scheme')

local host = Cg((any - S':/')^1, 'host')

local port =
  P':'
  * Cg(digit^1, 'port')

local path = Cg(any^0, 'path')

local authority = 
  userInfo^0
  * host
  * port^0


local input = io.read()
local body, query, fragment = split(input, '?#')

local patt = Ct(
  (
    (scheme * P'://' * authority)^1
    + (P'//' * userInfo * P'@'^-1 * host * port)
    + (P'//' * #P'/')
    + (scheme * P':')^-1
  )
  * path
)

local res = match(patt, body)

print 'Map('

print("[scheme] => "..emptyToNull(res.scheme))
print("[host] => "..emptyToNull(res.host))
if not res.port or res.port == '' then
  res.port = '-1'
end
print("[port] => "..emptyToNull(res.port))
print("[user] => "..emptyToNull(res.user))
print("[pass] => "..emptyToNull(res.pass))

print("[path] => "..emptyToNull(res.path))
print("[query] => "..emptyToNull(query))
print("[fragment] => "..emptyToNull(fragment))

print ')'
