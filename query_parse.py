#!/usr/bin/python3

import sys

def parseQuery(content):
  groups = content.split('?')
  nonEmptyGroups = [g for g in groups if g != '']
  # Only split once, so key will be anything before the first '='-sign
  # and value can contain additional equal signs
  splits = [g.split('=', 1) for g in nonEmptyGroups]
  for (k, v) in splits:
    if k.strip() == '': #Empty keys make no sense
      return None
  return splits

parsed = parseQuery(sys.stdin.read().replace("\n", ""))

if not parsed:
  print("Invalid input")
else:
  print('Map(')
  for (key, value) in parsed:
    print('[%s] => %s' % (key, value))
  print(')')


