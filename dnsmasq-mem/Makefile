all: run.log

run.log: dnsperf
	docker build -t dnsmasq-perf .
	docker run -it dnsmasq-perf /dnsmasq-mem.sh > run.log

dnsperf: 
	./build-dnsperf.sh

.PHONY: clean
clean:
	rm -f dnsperf
	rm -f run.log
