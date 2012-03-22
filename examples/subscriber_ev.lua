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

local zmq = require"zmq"
local z_NOBLOCK = zmq.NOBLOCK
local z_EVENTS = zmq.EVENTS
local z_POLLIN = zmq.POLLIN
local z_POLLOUT = zmq.POLLOUT
local z_POLLIN_OUT = z_POLLIN + z_POLLOUT
local ev = require'ev'
local loop = ev.Loop.default

-- define a sub_worker class
local sub_worker_mt = {}
function sub_worker_mt:close(...)
	self.s_io_idle:stop(self.loop)
	self.s_io_read:stop(self.loop)
	return self.socket:close(...)
end
function sub_worker_mt:bind(...)
	return self.socket:bind(...)
end
function sub_worker_mt:connect(...)
	return self.socket:connect(...)
end
function sub_worker_mt:sub(topic)
	return self.socket:setopt(zmq.SUBSCRIBE, topic)
end
function sub_worker_mt:unsub(topic)
	return self.socket:setopt(zmq.UNSUBSCRIBE, topic)
end
sub_worker_mt.__index = sub_worker_mt

local function sub_worker(loop, ctx, msg_cb)
	local s = ctx:socket(zmq.SUB)
	local self = { loop = loop, socket = s, msg_cb = msg_cb }
	setmetatable(self, sub_worker_mt)
	-- create ev callbacks for recving data.
	-- need idle watcher since ZeroMQ sockets are edge-triggered instead of level-triggered
	local s_io_idle
	local s_io_read
	local max_recvs = 10
	local function s_recv(recv_cnt)
		local msg, err = s:recv(z_NOBLOCK)
		if err == 'timeout' then
			-- need to block on read IO
			return false
		end
		self:msg_cb(msg)
		if recv_cnt > 1 then
			return s_recv(recv_cnt - 1)
		end
		return true
	end
	s_io_idle = ev.Idle.new(function()
		if not s_recv(max_recvs) then
			-- need to block on read IO
			s_io_idle:stop(loop)
			s_io_read:start(loop)
		end
	end)
	s_io_idle:start(loop)
	s_io_read = ev.IO.new(function()
		local events = s:getopt(z_EVENTS)
		if events == z_POLLIN or events == z_POLLIN_OUT then
			if s_recv(max_recvs) then
				-- read IO is not block, enable idle watcher to handle reads.
				s_io_idle:start(loop)
				s_io_read:stop(loop)
			end
		end
	end, s:getopt(zmq.FD), ev.READ)
	self.s_io_idle = s_io_idle
	self.s_io_read = s_io_read
	return self
end

local ctx = zmq.init()

-- message handling function.
local function handle_msg(worker, msg)
	local msg_id = tonumber(msg)
	if math.mod(msg_id, 10000) == 0 then print(worker.id, msg_id) end
end

local sub1 = sub_worker(loop, ctx, handle_msg)
sub1.id = 'sub1'
sub1:sub('')
sub1:connect("tcp://localhost:5555")
local sub2 = sub_worker(loop, ctx, handle_msg)
sub2.id = 'sub2'
sub2:sub('')
sub2:connect("tcp://localhost:5555")

loop:loop()

