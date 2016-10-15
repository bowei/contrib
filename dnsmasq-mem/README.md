# Dnsmasq memory consumption

To reproduce these results:

https://github.com/bowei/contrib/tree/dnsmasq-mem/dnsmasq-mem

## TLDR

dnsmasq in its current configuration caps the size of its cache to 10k records.
(See `src/options.c`) It will not use more than 3mb for typical workloads. When
the cache limit was removed, we get the following memory usage scaling:

cache size | memory footprint
-----------|-----------------
10k        | 3 mb
100k       | 13 mb
1M         | 112 mb

# Dnsmasq notes

* Does not cache entry types that are unbounded in memory usage (e.g.
  TXT records).
* Each record in a response consumes a single entry in the cache. E.g. if 
  foo.com has 5 A records returned, then this will consume 5 entries.
* If a response with multiple records does not fit in the cache, it is not
  cached.

# Evaluation details

Evaluation consists of a bind9 server configured to result synthetic records
(A, AAAA, TXT, SRV), a dnsmasq instance and dnsperf client:

````
  +------+       +---------+       +---------+
  | bind | <---- | dnsmasq | <---- | dnsperf |
  +------+       +---------+       +---------+
````

`make` will build the docker images and run the memory consumption harness. The
resulting `run.log` will contain the resulting memory used by dnsmasq after
fully populating its cache.
