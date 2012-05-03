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

local z_EVENTS = zmq.EVENTS

local z_POLLIN = zmq.POLLIN
local z_POLLOUT = zmq.POLLOUT
local z_POLLIN_OUT = z_POLLIN + z_POLLOUT

local poll

local meths = {}
local zsock_mt = { __index=meths }

local function zsock_check_events(self)
	if not self.check_enabled then
		-- enable 'on_work' callback to handle checking for socket events.
		self.check_enabled = true
		poll:add_work(self.on_work)
	end
end

function meths:events()
	zsock_check_events(self)
	return self.sock:events()
end

function meths:getopt(opt)
	if (opt == z_EVENTS) then
		zsock_check_events(self)
	end
	return self.sock:getopt(opt)
end

function meths:setopt(opt,val)
	return self.sock:setopt(opt,val)
end

function meths:sub(topic)
	return self.sock:sub(topic)
end

function meths:unsub(topic)
	return self.sock:unsub(topic)
end

function meths:identity(id)
	return self.sock:identity(id)
end

function meths:bind(addr)
	return self.sock:bind(addr)
end

function meths:connect(addr)
	return self.sock:connect(addr)
end

function meths:close()
	return self.sock:close()
end

function meths:send(msg, flags)
	zsock_check_events(self)
	local sent, err = self.sock:send(msg, flags)
	if not sent and err == 'timeout' then
		self.send_blocked = true
	end
	return sent, err
end

function meths:send_msg(msg, flags)
	zsock_check_events(self)
	local sent, err = self.sock:send_msg(msg, flags)
	if not sent and err == 'timeout' then
		self.send_blocked = true
	end
	return sent, err
end

function meths:recv(flags)
	zsock_check_events(self)
	local msg, err = self.sock:recv(flags)
	if not msg and err == 'timeout' then
		self.recv_blocked = true
	end
	return msg, err
end

function meths:recv_msg(msg, flags)
	zsock_check_events(self)
	local stat, err = self.sock:recv_msg(msg, flags)
	if not stat and err == 'timeout' then
		self.recv_blocked = true
	end
	return stat, err
end

local function nil_cb()
end

local function wrap_zsock(sock, on_data, on_drain)
	local self = setmetatable({
		sock = sock,
		on_data = on_data or nil_cb,
		on_drain = on_drain or nil_cb,
		recv_blocked = false,
		send_blocked = false,
		check_enabled = false,
	}, zsock_mt)

	local function on_work()
		self.check_enabled = false
		local events = sock:events()
		local read = false
		local write = false
		if events == z_POLLIN_OUT then
			read = true
			write = true
		elseif events == z_POLLIN then
			read = true
		elseif events == z_POLLOUT then
			write = true
		else
			return
		end
		if read then
			self.recv_blocked = false
			self:on_data(sock)
			-- there might be more messages to read.
			if not self.recv_blocked then
				zsock_check_events(self)
			end
		end
		if write and self.send_blocked then
			self:on_drain(sock)
		end
	end
	self.on_work = on_work

	-- listen for read events to enable socket.
	poll:add_read(sock:fd(), function()
		on_work()
	end)

	zsock_check_events(self)
	return self
end

return setmetatable({
set_poller = function(poller)
	local old = poll
	poll = poller
	return old
end,
wrap_zsock = wrap_zsock,
}, { __call = function(tab, ...) return wrap_zsock(...) end})

