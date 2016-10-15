import argparse

parser = argparse.ArgumentParser()
parser.add_argument('--type', type=str, default='a')
parser.add_argument('--size', type=int, default=1)
parser.add_argument('--entries', type=int, default=1)
args = parser.parse_args()

if args.type == 'a':
  for i in range(args.entries):
    print 'x{}.{}.a.test.net. A'.format(i, args.size)
elif args.type == 'aaaa':
  for i in range(args.entries):
    print 'x{}.{}.aaaa.test.net. AAAA'.format(i, args.size)
elif args.type == 'txt':
  for i in range(args.entries):
    print 'x{}.{}.txt.test.net. AAAA'.format(i, args.size)
elif args.type == 'svr':
  for i in range(args.entries):
    print '_http._tcp.{}-{}.srv.test.net.'.format(i, args.size)
