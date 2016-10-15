FROM alpine
MAINTAINER Bowei Du <bowei@google.com>

RUN apk update && apk add bind bind-tools python dnsmasq openssl-dev libcap-dev

ADD genzone.py /genzone.py
COPY named.conf /etc/bind/named.conf

RUN mkdir -p /var/cache/bind

ADD dnsmasq-mem.sh /dnsmasq-mem.sh
ADD dataset.py /dataset.py
ADD dnsperf /dnsperf
