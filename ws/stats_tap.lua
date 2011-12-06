-- Copyright (c) 2011, Robert G. Jakabosky <bobby@sharedrealm.com> All rights reserved.

local tap = require"zmq.ws.tap"

local format = string.format

local stats_tap_mt = {}
stats_tap_mt.__index = stats_tap_mt

function stats_tap_mt:packet(pinfo, tvb, tree, data)
	-- count all ZeroMQ packets
	self.count = self.count + 1
	data = data or pinfo.tap_data
	if not data then
		return
	end
	-- frames
	self.frames = self.frames + (data.frames or 0)
	-- frames with more flag set
	self.more = self.more + (data.more or 0)
	-- whole messages.
	self.msgs = self.msgs + (data.msgs or 0)
	-- total bytes in frame bodies.
	self.body_bytes = self.body_bytes + (data.body_bytes or 0)
end

function stats_tap_mt:draw()
	return format([[
ZeroMQ Packets: %d
Frames: %d
Messages: %d
Flags: More: %d
Payload bytes: %d
]],
	self.count,
	self.frames,
	self.msgs,
	self.more,
	self.body_bytes)
end

function stats_tap_mt:reset()
	self.count = 0
	self.frames = 0
	self.msgs = 0
	self.more = 0
	self.body_bytes = 0
end

local function create_stats_tap()
	local tap = setmetatable({}, stats_tap_mt)

	tap:reset() -- initialize tap.
	return tap, 'zmq', 'lua'
end

tap("ZeroMQ stats tap", create_stats_tap)

