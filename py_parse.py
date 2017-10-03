#!/usr/bin/python3

import sys

NULL = 'null'
NO_PORT = '-1'

def extractFragment(content):
  fragmentSplit = content.split('#')
  if len(fragmentSplit) == 2:
    return fragmentSplit
  else:
    return (content, NULL)


def extractQueryAndFragment(content):
  querySplit = content.split('?', 1)
  if len(querySplit) == 2:
    (query, fragment) = extractFragment(querySplit[1])
    return (querySplit[0], query, fragment)
  else:
    return (content, NULL, NULL)


def extractScheme(content):
  if content[0] == '/':
    return (NULL, content)
  else:
    schemeSplit = content.split(':', 1) # Only split once on first occurance
    if len(schemeSplit) > 1 and schemeSplit[0].find('/') == -1:
      return (schemeSplit[0], schemeSplit[1])
    else:
      return (NULL, content)


def extractPath(bodyContent):
  if bodyContent[:2] == "//":
    pathSplit = bodyContent[2:].split('/', 1)
    return (pathSplit[0], '/'+pathSplit[1])
  else:
    return (NULL, bodyContent)


def extractUserInfo(content):
  if content == '':
    return (NULL, NULL, content)
  if len(content) > 2 and content[:3] == '///':
    return (NULL, NULL, content[2:])

  userInfoSplit = content.split('@')
  # user info has to follow '//'
  if len(userInfoSplit) > 1 and userInfoSplit[0][:2] == '//':
    (user, password) = userInfoSplit[0].split(':')
    user = user[2:] # split off leading '//' from user
    # Add back '//' to returned rest
    return (user if len(user) > 1 else NULL, password or NULL, '//'+userInfoSplit[1])
  else:
    # No @-sign or no leading '//', no user info
    return (NULL, NULL, content)


def extractHost(content):
  if content == '' or not (content[:2] == '//' or content[0] == '@'):
    return (NULL, content)

  if content[0] == '@':
    content = content[1:]
  else:
    content = content[2:]

  colonInd = content.find(':')
  slashInd = content.find('/')
  hasPort = False
  hostSplit = []
  if colonInd != -1 and (slashInd == -1 or colonInd < slashInd):
    hasPort = True
    hostSplit = content.split(':', 1)
  elif slashInd != -1:
    hostSplit = content.split('/', 1)

  if len(hostSplit) > 1:
    (host, rest) = hostSplit
    if hasPort:
      rest = ':'+rest
    else:
      rest  = '/'+rest
    return (host, rest)
  elif colonInd == -1 and slashInd == -1:
    return (content, '')
  else:
    return (NULL, content)


def extractPort(content):
  if content == '' or content[0] != ':':
    return (NO_PORT, content)
  else:
    portSplit = content[1:].split('/', 1)
    if len(portSplit) > 1:
      port = portSplit[0]
      rest = '/'+portSplit[1]
    else:
      port = content[1:]
      rest = ''
    return (port if port != '' else NO_PORT, rest)


def parseURL(content):
  result = {}

  (rest, result['query'], result['fragment']) = extractQueryAndFragment(content)
  (result['scheme'], rest) = extractScheme(rest)
  if len(rest) > 1 and rest[:2] == '//' and rest[3] != '/':
    (result['user'], result['pass'], rest) = extractUserInfo(rest)
    (result['host'], rest) = extractHost(rest)
    (result['port'], result['path']) = extractPort(rest);
    if result['path'] == '':
      result['path'] = NULL
  else:
    result['user'] = result['pass'] = result['host'] = NULL
    result['port'] = NO_PORT
    if len(rest) > 1 and rest[:2] == '//':
      rest = rest[2:]
    result['path'] = rest


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

  parsed = parseURL(sys.stdin.read().replace("\n", ""))

  print("Map(")
  for key in keys:
    print("[%s] => %s" % (key, parsed[key]))
  print(")")
