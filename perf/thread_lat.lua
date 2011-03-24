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

if #arg < 4 then
    print("usage: lua " .. arg[0] .. " <bind-to> <connect-to> <message-size> <roundtrip-count>")
    os.exit()
end

local bind_to = arg[1]
local connect_to = arg[2]
local message_size = tonumber(arg[3])
local roundtrip_count = tonumber(arg[4])

local zmq = require"zmq"
local thread = require"zmq.thread"

local socket = require"socket"
local time = socket.gettime

local child_code = [[
	local connect_to, message_size, roundtrip_count = ...
	print("child:", ...)

	local zmq = require"zmq"
	local thread = require"zmq.thread"

	local ctx = thread.get_parent_ctx()
	local s = ctx:socket(zmq.REP)
	s:connect(connect_to)

	local msg = zmq.zmq_msg_t()

	for i = 1, roundtrip_count do
		assert(s:recv_msg(msg))
		assert(msg:size() == message_size, "Invalid message size")
		assert(s:send_msg(msg))
	end

	s:close()
]]

local ctx = zmq.init(1)
local s = ctx:socket(zmq.REQ)
s:bind(bind_to)

local child_thread = thread.runstring(ctx, child_code, connect_to, message_size, roundtrip_count)
child_thread:start()

local data = ("0"):rep(message_size)
local msg = zmq.zmq_msg_t.init_size(message_size)

local start_time = time()

for i = 1, roundtrip_count do
	assert(s:send_msg(msg))
	assert(s:recv_msg(msg))
	assert(msg:size() == message_size, "Invalid message size")
end

local end_time = time()

local elapsed = end_time - start_time
local latency = elapsed * 1000000 / roundtrip_count / 2

print(string.format("message size: %i [B]", message_size))
print(string.format("roundtrip count: %i", roundtrip_count))
print(string.format("mean latency: %.3f [us]", latency))

s:close()
ctx:term()


