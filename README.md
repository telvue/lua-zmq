About
=====

Lua bindings to zeromq2.

Installation
============

	$ luarocks install https://github.com/Neopallium/lua-zmq/raw/master/rockspecs/lua-zmq-scm-1.rockspec

Running benchmarks
==================

When running the benchmarks you will need run two different scripts (one 'local' and one 'remote').  Both scripts can be run on the same computer or on different computers.  Make sure to start the 'local' script first.

Throughput benchmark:
	# first start local script
	$ luajit-2 perf/local_thr.lua "tcp://lo:5555" 50 1000000
	
	# then in another window start remote script
	$ luajit-2 perf/remote_thr.lua "tcp://localhost:5555" 50 1000000

Latency benchmark:
	# first start local script
	$ luajit-2 perf/local_lat.lua "tcp://lo:5555" 1 100000
	
	# then in another window start remote script
	$ luajit-2 perf/remote_lat.lua "tcp://localhost:5555" 1 100000

You can disable the FFI support when running under LuaJIT2 by passing a forth parameter `disable_ffi`

API
===

See [API.md](http://github.com/iamaleksey/lua-zmq/blob/master/API.md) and
[ØMQ docs](http://www.zeromq.org/area:docs-v20).
