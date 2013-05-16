-- Copyright (c) 2011 Robert G. Jakabosky <bobby@sharedrealm.com>
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

if #arg < 1 then
    print("usage: lua " .. arg[0] .. " [message-size] [roundtrip-count] [bind-to] [connect-to]")
end

local message_size = tonumber(arg[1] or 1)
local roundtrip_count = tonumber(arg[2] or 100)
local bind_to = arg[3] or 'inproc://thread_lat_test'
local connect_to = arg[4] or 'inproc://thread_lat_test'

local zmq = require"zmq"

local ctx = zmq.init(1)
local server = assert(ctx:socket(zmq.REQ))
assert(server:bind(bind_to))

local client = ctx:socket(zmq.REP)
client:connect(connect_to)

local data = ("0"):rep(message_size)
local msg = zmq.zmq_msg_t.init_size(message_size)
local client_msg = zmq.zmq_msg_t()

print(string.format("message size: %i [B]", message_size))
print(string.format("roundtrip count: %i", roundtrip_count))

local timer = zmq.stopwatch_start()

for i = 1, roundtrip_count do
	-- server send
	assert(server:send_msg(msg))

	-- client recv
	assert(client:recv_msg(client_msg))
	assert(client_msg:size() == message_size, "Invalid message size")
	-- client send
	assert(client:send_msg(client_msg))

	-- server recv
	assert(server:recv_msg(msg))
	assert(msg:size() == message_size, "Invalid message size")
end

local elapsed = timer:stop()

server:close()
client:close()
ctx:term()

local latency = elapsed / roundtrip_count / 2

print(string.format("mean latency: %.3f [us]", latency))
local secs = elapsed / (1000 * 1000)
print(string.format("elapsed = %f", secs))
print(string.format("msg/sec = %f", roundtrip_count / secs))

