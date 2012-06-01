local zmq = require'zmq'
local poller = require"examples.poller"
local poll_zsock = require"examples.poll_zsock"

local poll = poller.new()
poll_zsock.set_poller(poll)

local c = zmq.init(1)
local xreq = poll_zsock(c:socket(zmq.XREQ))
xreq:bind('tcp://127.0.0.1:13333')
local xrep = poll_zsock(c:socket(zmq.XREP))
xrep:bind('tcp://127.0.0.1:13334')

local max_recv = 10

local function forward_io(src,dst)
	src.on_data = function()
		for i=1,max_recv do
			repeat
				local data, err = src:recv(zmq.NOBLOCK)
					if not data then
						if err == 'timeout' then
							return
						else
							error("socket recv error:" .. err)
						end
					end
				local more = src:getopt(zmq.RCVMORE) > 0
				dst:send(data,more and zmq.SNDMORE or 0)
			until not more
		end
	end
end

forward_io(xrep,xreq)
forward_io(xreq,xrep)

poll:start()

