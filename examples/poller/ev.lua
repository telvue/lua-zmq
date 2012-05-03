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

local ev = require'ev'
local ev_READ = ev.READ
local ev_WRITE = ev.WRITE
local loop = ev.Loop.default

assert(ev.Idle,"Need version > 1.3 of lua-ev that supports Idle watchers.")

local poller_meths = {}
local poller_mt = {__index = poller_meths}

local function poller_new()
	local self = {
		work_cur = {},
		work_last = {},
		io_events = 0,
		reads = {},
		idle_enabled = false,
	}

	self.idle = ev.Idle.new(function()
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
			-- check if there is more work.
			if #cur > 0 then
				return -- don't disable idle watcher, when we have work.
			end
		end
--print("STOP IDLE:", #self.work_cur, #self.work_last)
		-- stop idle watcher, no work.
		self.idle_enabled = false
		self.idle:stop(loop)
	end)
	-- set priority to max, to make sure the work queue is processed on each loop.
	self.idle:priority(ev.MAXPRI)

	return setmetatable(self, poller_mt)
end

function poller_meths:add_work(task)
	local idx = #self.work_cur + 1
	-- add task to current work queue.
	self.work_cur[idx] = task
	-- make sure the idle watcher is enabled.
	if not self.idle_enabled then
		self.idle_enabled = true
		self.idle:start(loop)
	end
end

function poller_meths:add_read(fd, cb)
	local io_read = self.reads[fd]
	-- make sure read event hasn't been registered yet.
	if not io_read then
		self.io_events = self.io_events + 1
		io_read = ev.IO.new(function()
			cb(fd)
		end, fd, ev_READ)
		self.reads[fd] = io_read
		io_read:start(loop)
	else
		-- update read callback?
		io_read:callback(cb)
		-- need to re-start watcher?
		if not io_read:is_active() then
			io_read:start(loop)
		end
	end
end

function poller_meths:remove_read(fd)
	local io_read = self.reads[fd]
	-- make sure there was a read event registered.
	if io_read then
		self.io_events = self.io_events - 1
		io_read:stop(loop)
	end
end

function poller_meths:start()
	return loop:loop()
end

function poller_meths:stop()
	return loop:unloop()
end

-- module only exports a 'new' function.
return {
new = poller_new,
}
