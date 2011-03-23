--
-- zmq.poller wraps the low-level zmq.zmq_poller object.
--
-- This wrapper simplifies the event polling loop.
--

local zmq = require"zmq"

local setmetatable = setmetatable
local tonumber = tonumber
local assert = assert

local poller_mt = {}
poller_mt.__index = poller_mt

function poller_mt:add(sock, events, cb)
	self.poller:add(sock, events)
	self.callbacks[sock] = cb
end

function poller_mt:modify(sock, events, cb)
	if events ~= 0 and cb then
		self.callbacks[sock] = cb
		self.poller:modify(sock, events)
	else
		self:remove(sock)
	end
end

function poller_mt:remove(sock)
	self.poller:remove(sock)
	self.callbacks[sock] = nil
end

function poller_mt:poll(timeout)
	local poller = self.poller
	local status, err = poller:poll(-1)
	if not status then
		return false, err
	end
	local callbacks = self.callbacks
	while true do
		local sock, revents = poller:next_revents()
		if not sock then
			break
		end
		local cb = callbacks[sock]
		if cb then
			cb(sock, revents)
		end
	end
	return true
end

function poller_mt:start()
	self.is_running = true
	while self.is_running do
		self:poll(-1)
	end
end

function poller_mt:stop()
	self.is_running = false
end

module(...)

function new(pre_alloc)
	return setmetatable({
		poller = zmq.zmq_poller(pre_alloc),
		callbacks = setmetatable({}, {__mode="k"}),
	}, poller_mt)
end

setmetatable(_M, {__call = function(tab, ...) return new(...) end})

