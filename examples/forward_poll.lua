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

local function forward_io(src,dst)
   src.on_data = function()
      repeat
         local data = assert(src:recv(zmq.NOBLOCK))
         local more = src:getopt(zmq.RCVMORE) > 0
         dst:send(data,more and zmq.SNDMORE or 0)
      until not more
   end
end

forward_io(xrep,xreq)
forward_io(xreq,xrep)

poll:start()

