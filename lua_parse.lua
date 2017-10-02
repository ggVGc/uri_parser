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
local separators = S':/' -- URI separators are colon and slash
local userInfoSeparators = separators + P'@' -- Except for userInfo.. where @ is the delimiter

local userPassContent = (any - userInfoSeparators)^0

-- user:password followed by @-sign. Either part can be empty, but ':' is mandatory
local userInfo =
  (
    Cg(userPassContent, 'user')
    * P':'
    * Cg(userPassContent, 'pass')
  )^1
  * P'@'

local scheme = Cg((any - separators)^1, 'scheme')
local host = Cg((any - separators)^1, 'host')

local port =
  P':'
  * Cg(digit^1, 'port')

local authority = 
  (userInfo + P'@')^0 -- optional user info. Lone @ is ignored
  * host -- might be empty
  * port^0 -- optional


local input = io.read()
local body, query, fragment = split(input, '?#')

local patt = Ct(
  (
    ((scheme * P':')^-1 * P'//' * authority)^1
    + (scheme * P':')^-1 -- non-URL. Everything after scheme is path
  )
  * (
    (P'//' * Cg(P'/' * any^0, 'path'))
    + Cg(any^0, 'path')
  )
)

local res = match(patt, body)

if not res.port or res.port == '' then
  res.port = '-1'
end

print 'Map('
print("[scheme] => "..emptyToNull(res.scheme))
print("[host] => "..emptyToNull(res.host))
print("[port] => "..res.port)
print("[user] => "..emptyToNull(res.user))
print("[pass] => "..emptyToNull(res.pass))
print("[path] => "..emptyToNull(res.path))
print("[query] => "..emptyToNull(query))
print("[fragment] => "..emptyToNull(fragment))
print ')'
