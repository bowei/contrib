#!/bin/bash

dnsperf_tgz_url=${dnsperf_tgz_url:-ftp://ftp.nominum.com/pub/nominum/dnsperf/2.1.0.0/dnsperf-src-2.1.0.0-1.tar.gz}

set -e

echo "build dnsperf for the alpine distribution"

curl ${dnsperf_tgz_url} > dnsperf.tgz
docker build -f Dockerfile.dnsperf -t dnsperf-build .
docker run dnsperf-build /bin/sh -c \
  "cd /tmp && tar -zxf dnsperf.tgz && cd dnsperf* && ./configure && make && cp dnsperf /"
container_id=`docker ps -l -q`
docker cp ${container_id}:/dnsperf .
