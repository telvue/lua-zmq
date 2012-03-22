-- Copyright (c) 2012 Robert G. Jakabosky <bobby@sharedrealm.com>
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.

local poller = require"examples.poller"
local poll = poller.new()

local zmq = require"zmq"
local z_NOBLOCK = zmq.NOBLOCK
local z_EVENTS = zmq.EVENTS
local z_POLLIN = zmq.POLLIN
local z_POLLOUT = zmq.POLLOUT
local z_POLLIN_OUT = z_POLLIN + z_POLLOUT

local N=tonumber(arg[1] or 100)

local ctx = zmq.init()
local s = ctx:socket(zmq.SUB)
local s_FD = s:getopt(zmq.FD)

s:setopt(zmq.SUBSCRIBE, "")
s:connect("tcp://localhost:5555")

-- current socket state
local blocked_state
local blocked_event
local on_sock_recv
local on_sock_send

-- IO event callback when socket was blocked
local function on_sock_io()
	local events = s:getopt(z_EVENTS)
	local unblocked = false
	if events == blocked_event then
		-- got the event the socket was blocked on.
		unblocked = true
	elseif events == z_POLLIN_OUT then
		-- got both in & out events
		unblocked = true
	end
	if unblocked then
		-- got the event we are blocked on resume.
		blocked_event = nil
		blocked_state()
		-- check if blocked event was processed.
		if not blocked_event then
			poll:remove_read(s_FD)
		end
	end
end
local function sock_blocked(state, event)
	if not blocked_event then
		-- need to register socket's fd with event loop
		poll:add_read(s_FD, on_sock_io)
	end
	blocked_state = state
	blocked_event = event
end

-- sock state functions
function on_sock_recv()
	local data, err = s:recv(z_NOBLOCK)
	if not data then
		assert(err == 'timeout', "Bad error on zmq socket.")
		return sock_blocked(on_sock_recv, z_POLLIN)
	end
	local msg_id = tonumber(data)
	if (msg_id % 10000) == 0 then print(data) end
	return on_sock_recv()
end

-- start processing of the socket.
poll:add_work(on_sock_recv)

-- start event loop
poll:start()

s:close()
ctx:term()

