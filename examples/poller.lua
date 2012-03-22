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

local epoll = require"epoll"
local EPOLLIN = epoll.EPOLLIN
local EPOLLOUT = epoll.EPOLLOUT

local poller_meths = {}
local poller_mt = {__index = poller_meths}

local function poller_new()
	local reads = {}
	-- create closure for epoll io_event callback.
	local function do_io_event(fd, ev)
		local cb = reads[fd]
		return cb(fd, ev)
	end

	return setmetatable({
		work_cur = {},
		work_last = {},
		reads = reads,
		io_events = 0,
		do_io_event = do_io_event,
		poller = epoll.new(),
	}, poller_mt)
end

function poller_meths:add_work(task)
	-- add task to current work queue.
	self.work_cur[#self.work_cur + 1] = task
end

function poller_meths:add_read(fd, cb)
	-- make sure read event hasn't been registered yet.
	if not self.reads[fd] then
		self.io_events = self.io_events + 1
		self.reads[fd] = cb
		return self.poller:add(fd, EPOLLIN, fd)
	else
		-- update read callback?
		self.reads[fd] = cb
	end
end

function poller_meths:remove_read(fd)
	-- make sure there was a read event registered.
	if self.reads[fd] then
		self.io_events = self.io_events - 1
		self.reads[fd] = nil
		return self.poller:del(fd)
	end
end

local function poller_do_work(self)
	local tasks = #self.work_cur
	-- check if there is any work
	if tasks > 0 then
		-- swap work queues.
		local last, cur = self.work_cur, self.work_last
		self.work_cur, self.work_last = cur, last
		for i=1,tasks do
			local task = last[i]
			last[i] = nil
			task()
		end
		-- return new work queue length.
		return #cur
	end
	return tasks
end

function poller_meths:start()
	local do_io_event = self.do_io_event
	local poller = self.poller
	self.is_running = true
	while self.is_running do
		-- run work task
		local new_work = poller_do_work(self)
		-- wait == 0, if there is work to do, else wait == -1
		local wait = (new_work > 0) and 0 or -1
		-- poll for fd events, if there are events to poll for.
--print("poller:step()", new_work, self.io_events)
		if self.io_events > 0 then
			assert(poller:wait_callback(do_io_event, wait))
		else
			-- no io events to poll, do we still have work?
			if #self.work_cur == 0 then
				-- nothing to do, exit event loop
				self.is_running = false
				return
			end
		end
	end
end

function poller_meths:stop()
	self.is_running = false
end

-- module only exports a 'new' function.
return {
new = poller_new,
}
