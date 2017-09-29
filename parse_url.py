#!/usr/bin/python

import sys

def extractFragment(content):
  splitRes = content.split('#')
  if len(splitRes) == 2:
    return splitRes
  else:
    return (content, "null")


def extractQueryAndFragment(content):
  splitRes = content.split('?')
  if len(splitRes) == 2:
    return extractFragment(splitRes[1])
  else:
    return ("null", "null")


def parseURI(content):
  result = {}

  (result['query'], result['fragment']) = extractQueryAndFragment(content)
  # result['fragment'] = parseFragment(queryAndFragment)


  return result


if __name__ == "__main__":
  print("Map(")
  for key, value in parseURI(sys.stdin.read().replace("\n", "")).items():
    print("[%s] => %s" % (key, value))
  print(")")
