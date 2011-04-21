## constants

ZMQ_CONSTANT_NAME in the C API turns into zmq.CONSTANT_NAME in Lua.

## version()

Reports 0MQ library version.
See [zmq_version(3)](http://api.zeromq.org/zmq_version.html).

	zmq.version()

## init(io_threads)

Initialises ØMQ context.
See [zmq_init(3)](http://api.zeromq.org/zmq_init.html).

	zmq.init(io_threads)  

# ZMQ Context methods

## term()

Terminates ØMQ context.
See [zmq_term(3)](http://api.zeromq.org/zmq_term.html).

	ctx:term()

## socket(type)

Creates ØMQ socket.
See [zmq_socket(3)](http://api.zeromq.org/zmq_socket.html).

	ctx:socket(type)

# ZMQ Socket methods

## close()

Destroys ØMQ socket.
See [zmq_close(3)](http://api.zeromq.org/zmq_close.html).

	sock:close()

## setopt(option, optval)

Sets a specified option on a ØMQ socket.
See [zmq_setsockopt(3)](http://api.zeromq.org/zmq_setsockopt.html).

	sock:setopt(option, optval)

## getopt(option)

Gets a specified option of a ØMQ socket.
See [zmq_getsockopt(3)](http://api.zeromq.org/zmq_getsockopt.html).

	sock:getopt(option)

## bind(addr)

Binds the socket to the specified address.
See [zmq_bind(3)](http://api.zeromq.org/zmq_bind.html).

	sock:bind(addr)

## connect(addr)

Connect the socket to the specified address.
See [zmq_connect(3)](http://api.zeromq.org/zmq_connect.html).

	sock:connect(addr)

## send(msg [, flags])

Sends a message(Lua string).
See [zmq_send(3)](http://api.zeromq.org/zmq_send.html).

	sock:send(msg)
	sock:send(msg, flags)

## recv([flags])

Retrieves a message(a Lua string) from the socket.
See [zmq_recv(3)](http://api.zeromq.org/zmq_recv.html).

	msg = sock:recv()
	msg = sock:recv(flags)

# Zero-copy send_msg/recv_msg methods

These methods allow Zero-copy transfer of a message from one ZMQ socket to another.

## send_msg(msg [, flags])

Sends a message from a zmq_msg_t object.
See [zmq_send(3)](http://api.zeromq.org/zmq_send.html).

	sock:send_msg(msg)
	sock:send_msg(msg, flags)

## recv_msg(msg [, flags])

Retrieves a message from the socket into a zmq_msg_t object.
See [zmq_recv(3)](http://api.zeromq.org/zmq_recv.html).

	sock:recv_msg(msg)
	sock:recv_msg(msg, flags)

# zmq_msg_t object constructors

## zmq_msg_t.init()

Create an empty zmq_msg_t object.
See [zmq_msg_init(3)](http://api.zeromq.org/zmq_msg_init.html).

	local msg = zmq_msg_t.init()

## zmq_msg_t.init_size(size)

Create an empty zmq_msg_t object and allow space for a message of `size` bytes.
See [zmq_msg_init_size(3)](http://api.zeromq.org/zmq_msg_init_size.html).

	local msg = zmq_msg_t.init_size(size)
	msg:set_data(data) -- if (#data ~= size) then the message will be re-sized.

## zmq_msg_t.init_data(data)

Create an zmq_msg_t object initialized with the content of `data`.

	local msg = zmq_msg_t.init_data(data)
	-- that is the same as:
	local msg = zmq_msg_t.init_size(#data)
	msg:set_data(data)

# zmq_msg_t object methods

## move(src)

Move the contents of one message into another.
See [zmq_msg_move(3)](http://api.zeromq.org/zmq_msg_move.html).

	msg1:move(msg2) -- move contents from msg2 -> msg1

## copy(src)

Copy the contents of one message into another.
See [zmq_msg_copy(3)](http://api.zeromq.org/zmq_msg_copy.html).

	msg1:copy(msg2) -- copy contents from msg2 -> msg1

## set_data(data)

Change the message contents.
See [zmq_msg_data(3)](http://api.zeromq.org/zmq_msg_data.html).

	msg:set_data(data) -- replace/set the message contents to `data`

## data()

Get the message contents.
See [zmq_msg_data(3)](http://api.zeromq.org/zmq_msg_data.html).

	local data = msg:data() -- get the message contents

## size()

Get the size of the message contents.
See [zmq_msg_size(3)](http://api.zeromq.org/zmq_msg_size.html).

	local size = msg:size()

## close()

Free the message contents and invalid the zmq_msg_t userdata object.
See [zmq_msg_close(3)](http://api.zeromq.org/zmq_msg_close.html).

	msg:close() -- free message contents and invalid `msg`

# FD/ZMQ Socket poller object

The poller object wraps [zmq_poll()](http://api.zeromq.org/zmq_poll.html) to allow polling
of events from multiple ZMQ Sockets and/or normal sockets.

## zmq.poller([pre_alloc])

Construct a new poller object.  The optional `pre_alloc` parameter is to pre-size the poller
for the number of sockets it will handle (the size can grow dynamically as-needed).

	local poller = zmq.poller(64)

## add(socket|fd, events, callback)

Add a ZMQ Socket or fd to the poller.  `callback` will be called when one of the events
in `events` is raised.

	poller:add(sock, zmq.POLLIN, function(sock) print(sock, " is readable.") end)
	poller:add(sock, zmq.POLLOUT, function(sock) print(sock, " is writable.") end)
	poller:add(sock, zmq.POLLIN+zmq.POLLOUT, function(sock, revents)
		print(sock, " has events:", revents)
	end)

## modify(socket|fd, events, callback)

Change the `events` or `callback` for a socket/fd.

	-- first wait for read event.
	poller:add(sock, zmq.POLLIN, function(sock) print(sock, " is readable.") end)
	-- now wait for write event.
	poller:modify(sock, zmq.POLLOUT, function(sock) print(sock, " is writable.") end)

## remove(socket|fd)

Remove a socket/fd from the poller.

	-- first wait for read event.
	poller:add(sock, zmq.POLLIN, function(sock) print(sock, " is readable.") end)
	-- remove socket from poller.
	poller:remove(sock)

## poll(timeout)

Wait `timeout` microseconds for events on the registered sockets (timeout = -1, means
wait indefinitely).  If any events happen, then those events are dispatched.

	poller:poll(1000000) -- wait 1 second for events.

## start()

Start an event loop waiting for and dispatching events.

	poller:start()

## stop()

Stop the event loop.

	poller:stop()

