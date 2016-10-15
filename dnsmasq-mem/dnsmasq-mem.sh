#!/bin/sh

set -e

dry_run=0
bind_port=5053
dnsmasq_port=5054
log=/tmp/dnsmasq-mem.log

_() {
  if [ "$dry_run" -eq 1 ]; then
    echo -- "$@"
  else
    log "EXEC $@"
    "$@"
    return $?
  fi
}

log() {
  local date
  date=`date '+%m/%d %H:%M:%S'`
  echo "$date]" "$@"
  echo "$date]" "$@" >>${log}
}

load_dnsmasq() {
  local type size entries pid
  type=$1; shift
  size=$1; shift
  entries=$1; shift

  log "RUN load_dnsmasq ${type} ${size} ${entries}"
  
  dnsmasq -d -k -p ${dnsmasq_port} --no-resolv -c 10000 \
          -a 127.0.0.1 \
          -S "127.0.0.1#${bind_port}" -8 - \
          >>/tmp/dnsmasq.out 2>>/tmp/dnsmasq.err &
  pid=$!

  sleep 2                       # small delay for dnsmasq to start

  python dataset.py \
    --type ${type} \
    --size ${size} \
    --entries ${entries} \
    | /dnsperf -e -s 127.0.0.1 -p 5054 >>/tmp/dnsperf.log

  log "statm " `cat /proc/${pid}/statm`
  log "RSS " `cat /proc/${pid}/statm | awk '{print($2 * 4096)}'`

  kill -SIGUSR1 ${pid}          # dump dnsmasq cache stats
  sleep 1
  kill -9 ${pid} || true
}

log "Generating BIND zones"
python genzone.py > /etc/bind/db.net.test

log "Starting BIND daemon (this can take a while)"
_ named -g >/tmp/named.out 2>/tmp/named.err &
named_pid=$!

while true; do
  log "Waiting for BIND to start"
  if dig @127.0.0.1 +time=1 -p ${bind_port} >/dev/null; then
    break
  fi
  _ sleep 5;
done

log "------------------------------------------------------------------------------"
log "BIND started"
load_dnsmasq a 1 10000
load_dnsmasq a 100 10000
load_dnsmasq a 1000 10000
load_dnsmasq a 5000 10000
load_dnsmasq aaaa 1 10000
load_dnsmasq aaaa 100 10000
load_dnsmasq aaaa 1000 10000
load_dnsmasq aaaa 5000 10000
load_dnsmasq txt 100 10000
load_dnsmasq txt 1000 10000
load_dnsmasq txt 5000 10000
# load_dnsmasq srv 10 10000
# load_dnsmasq srv 100 10000

log "------------------------------------------------------------------------------"
log dnsmasq.out
cat /tmp/dnsmasq.out

log dnsmasq.err
cat /tmp/dnsmasq.err

log "------------------------------------------------------------------------------"
log dnsperf.log
cat /tmp/dnsperf.log
