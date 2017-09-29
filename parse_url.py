#!/usr/bin/python3

import sys

NULL = 'null'
NO_PORT = '-1'

def extractFragment(content):
  splitRes = content.split('#')
  if len(splitRes) == 2:
    return splitRes
  else:
    return (content, NULL)


def extractQueryAndFragment(content):
  splitRes = content.split('?')
  if len(splitRes) == 2:
    (query, fragment) = extractFragment(splitRes[1])
    return (splitRes[0], query, fragment)
  else:
    return (content, NULL, NULL)


def extractScheme(content):
  if content[0] == '/':
    return (NULL, content)
  else:
    splitRes = content.split(':', 1) # Only split once on first occurance
    if len(splitRes) > 1:
      return (splitRes[0], splitRes[1])
    else:
      return (NULL, content)


def extractPath(bodyContent):
  if bodyContent[:2] == "//":
    splitRes = bodyContent[2:].split('/', 1)
    return (splitRes[0], '/'+splitRes[1])
  else:
    return (NULL, bodyContent)


def extractUserInfo(authorityInfo):
  splitRes = authorityInfo.split('@')
  if len(splitRes) > 1:
    userInfoSplit = splitRes[0].split(':')
    return (userInfoSplit[0] or "", userInfoSplit[1] or NULL, splitRes[1])
  else:
    return (NULL, NULL, authorityInfo)


def extractHostAndPort(hostContent):
  splitRes = hostContent.split(':', 1)
  if len(splitRes) > 1:
    return splitRes
  else:
    return (hostContent, NO_PORT)



def parseURI(content):
  result = {}
  (uriHead, result['query'], result['fragment']) = extractQueryAndFragment(content)
  (result['scheme'], body) = extractScheme(uriHead)
  (authority, result['path']) = extractPath(body)
  (result['user'], result['pass'], hostInfo) = extractUserInfo(authority)
  (result['host'], result['port']) = extractHostAndPort(hostInfo)

  return result


if __name__ == "__main__":
  keys = [
      'scheme'
      ,'host'
      ,'port'
      ,'user'
      ,'pass'
      ,'path'
      ,'query'
      ,'fragment'
  ]

  parsed = parseURI(sys.stdin.read().replace("\n", ""))

  print("Map(")
  for key in keys:
    print("[%s] => %s" % (key, parsed[key]))
  print(")")
