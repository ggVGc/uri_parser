#!/usr/bin/python3
import itertools
perms = itertools.permutations

schemes = ['http://', 'ht55p:/', '//', '///', '////']
hostnames = ['hostname', 'hostname.com', 'host123name', '1hostname', '2hostname.co5m']
ports = ['', ':123', ':1', ':']
users = ['user', 'us5er', '1user', 'user1', '']
passwords = ['pass@', 'pa66@', '1pass@', 'pass1@', '@']
userinfos = ["%s:%s" % (u, p) for u in users for p in passwords]
queries = ['', '?', '?query', '?que??ry', '?qu23ry?']
fragments = ['', '#', '#fragment', '#2fragment', '#frag:2?ment']


for x in [
  "%s%s%s%s%s%s" % (scheme, userinfo, host, port, query, fragment)
  for scheme in schemes
  for host in hostnames
  for userinfo in userinfos
  for port in ports
  for query in queries
  for fragment in fragments
]: print(x)






