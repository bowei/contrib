#!/usr/bin/env python

"""
Generate a BIND zone file that have various wildcard entries for
record types we care about.
"""
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('--small', action='store_true')
args = parser.parse_args()

print """
$ORIGIN test.net.
$TTL 1D

@ 1D IN SOA test.net. hostmaster.test.net. (
  1              ; serial
  21600          ; refresh after 6 hours
  3600           ; retry after 1 hour
  604800         ; expire after 1 week
  86400)         ; minimum TTL of 1 day
@ IN NS localhost.
"""
opts = {
  'a': [1, 5, 10, 25, 50, 100, 200, 500, 1000, 5000],
  'aaaa' : [1, 5, 10, 25, 50, 100, 200, 500, 1000, 5000],
  'txt': [10, 100, 1000, 5000],
  'srv': {
      'servers': 100, # XXX
      'count': [1, 10, 100, 500]
  }
}

small_opts = {
  'a': [1, 5],
  'aaaa' : [1, 5],
  'txt': [10, 100],
  'srv': {
      'servers': 10,
      'count': [1, 10],
  }
}

if args.small:
  print '; using small set (for testing)'
  opts = small_opts

print '; A records (*.<count>.a.test.net)'
for count in opts['a']:
  print '*.{}.a IN A 172.16.0.0'.format(count)
  for i in range(1, count):
    print '  IN A 172.16.{}.{}'.format(i/256, i%256)
  print

print '; AAAA records  (*.<count>.aaaa.test.net)'
for count in opts['aaaa']:
  print '*.{}.aaaa IN AAAA ::1'.format(count)
  for i in range(1, count):
    print '  IN AAAA ::{:x}:{:x}'.format(i/256, i%256)
  print

print '; TXT  records (*.{10,...}.txt.test.net)'
def make_txt(size):
  ret = ''
  while size > 0:
    if ret: ret += ' '
    n = min(size, 255)
    ret += '"{}"'.format('x'*n)
    size -= n
  return ret

for size in opts['txt']:
  print '*.{}.txt IN TXT {}'.format(size, make_txt(size))

print '; SRV records _http._tcp.<server id>-<count>.srv.test.net'
for count in opts['srv']['count']:
  for server in range(opts['srv']['servers']):
    for i in range(count):
      print '_http._tcp.{}-{}.srv 86400 IN SRV 0 5 80 server-{}.1.a'.format(
          server, count, i)
