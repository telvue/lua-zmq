-- Copyright (c) 2011, Robert G. Jakabosky <bobby@sharedrealm.com> All rights reserved.

-- cache globals to local for speed.
local format=string.format
local tostring=tostring
local tonumber=tonumber
local sqrt=math.sqrt
local pairs=pairs

-- wireshark API globals
local Pref = Pref
local Proto = Proto
local ProtoField = ProtoField
local DissectorTable = DissectorTable
local ByteArray = ByteArray
local PI_MALFORMED = PI_MALFORMED
local PI_ERROR = PI_ERROR

-- zmq protocol example
-- declare our protocol
local zmq_proto = Proto("zmq","ZMQ","ZeroMQ Protocol")

-- setup preferences
zmq_proto.prefs["tcp_port_start"] =
	Pref.string("TCP port range start", "5555", "First TCP port to decode as this protocol")
zmq_proto.prefs["tcp_port_end"] =
	Pref.string("TCP port range end", "5555", "Last TCP port to decode as this protocol")
-- current preferences settings.
local current_settings = {
tcp_port_start = -1,
tcp_port_end = -1,
}

-- setup protocol fields.
zmq_proto.fields = {}
local fds = zmq_proto.fields
fds.frame = ProtoField.new("Frame", "zmq.frame", "ftypes.BYTES", nil, "base.NONE")
fds.length = ProtoField.new("Frame Length", "zmq.frame.len", "ftypes.UINT64", nil, "base.DEC")
fds.length8 = ProtoField.new("Frame 8bit Length", "zmq.frame.len8", "ftypes.UINT8", nil, "base.DEC")
fds.length64 = ProtoField.new("Frame 64bit Length", "zmq.frame.len64", "ftypes.UINT64", nil, "base.DEC")
fds.flags = ProtoField.new("Frame Flags", "zmq.frame.flags", "ftypes.UINT8", nil, "base.HEX", "0xFF")
fds.flags_more = ProtoField.new("More", "zmq.frame.flags.more", "ftypes.UINT8", nil, "base.HEX", "0x01")
fds.body = ProtoField.new("Frame body", "zmq.frame.body", "ftypes.BYTES", nil, "base.NONE")

-- un-register zmq to handle tcp port range
local function unregister_tcp_port_range(start_port, end_port)
	if not start_port or start_port <= 0 or not end_port or end_port <= 0 then
		return
	end
	local tcp_port_table = DissectorTable.get("tcp.port")
	for port = start_port,end_port do
		tcp_port_table:remove(port,zmq_proto)
	end
end

-- register zmq to handle tcp port range
local function register_tcp_port_range(start_port, end_port)
	if not start_port or start_port <= 0 or not end_port or end_port <= 0 then
		return
	end
	local tcp_port_table = DissectorTable.get("tcp.port")
	for port = start_port,end_port do
		tcp_port_table:add(port,zmq_proto)
	end
end

-- handle preferences changes.
function zmq_proto.init(arg1, arg2)
	local old_start, old_end
	local new_start, new_end
	-- check if preferences have changed.
	for pref_name,old_v in pairs(current_settings) do
		local new_v = zmq_proto.prefs[pref_name]
		if new_v ~= old_v then
			if pref_name == "tcp_port_start" then
				old_start = old_v
				new_start = new_v
			elseif pref_name == "tcp_port_end" then
				old_end = old_v
				new_end = new_v
			end
			-- save new value.
			current_settings[pref_name] = new_v
		end
	end
	-- un-register old port range
	if old_start and old_end then
		unregister_tcp_port_range(tonumber(old_start), tonumber(old_end))
	end
	-- register new port range.
	if new_start and new_end then
		register_tcp_port_range(tonumber(new_start), tonumber(new_end))
	end
end

-- parse flag bits.
local BITS = {
	MORE = 0x01,
	RESERVED = 0x7E,
}
local flag_names = {"MORE"}
local bits_lookup = {}
local bits_list = {
	{},
	{MORE = true},
	{MORE = true, RESERVED = true},
	{RESERVED = true},
}
local function parse_flags(flags)
	return bits_lookup[flags] or bits_lookup[1]
end

-- make bits object
local function make_bits(bits)
	local proxy = newproxy(true)
	local meta = getmetatable(proxy)
	meta.__index = bits
	meta.__tostring = function()
		return bits.flags
	end
	-- combind bits into string description.
	local flags = nil
	for i=1,#flag_names do
		local name = flag_names[i]
		if bits[name] then
			if flags then
				flags = flags .. ',' .. name
			else
				flags = name
			end
		end
	end
	-- combind bits into one byte value.
	local byte = 0x00
	for k,v in pairs(bits) do
		local bit = assert(BITS[k], "Invalid bit name.")
		byte = byte + BITS[k]
	end
	bits.flags = flags or ''
	bits.byte = byte
	return proxy
end
-- make bits objects in bis_lookup
for i=1,#bits_list do
	local bits = bits_list[i]
	bits = make_bits(bits)
	bits_lookup[bits.byte] = bits
end

local function zmq_dissect_frame(buffer, pinfo, frame_tree, tap)
	local rang,offset
	-- Frame length
	offset = 0
	local len_off = offset
	local len8_rang = buffer(offset,1)
	local len_rang = len8_rang
	local frame_len = len8_rang:uint()
		-- 8bit length field
	local ti = frame_tree:add(fds.length8, len8_rang)
	ti:set_hidden()
	offset = offset + 1
	if frame_len == 255 then
		local len64_rang = buffer(offset, 8)
		len_rang = buffer(len_off, 9)
		frame_len = tonumber(tostring(len64_rang:uint64()))
		-- 64bit length field.
		local ti = frame_tree:add(fds.length64, len64_rang)
		ti:set_hidden()
		offset = offset + 8
		local ti = frame_tree:add(fds.length, len_rang)
		ti:set_text(format("Frame Length: %d", frame_length))
	else
		frame_tree:add(fds.length, len_rang)
	end
	-- Frame flags
	rang = buffer(offset,1)
	local flags = rang:uint()
	local flags_bits = parse_flags(flags)
	local flags_list = flags_bits.flags
	local flags_tree = frame_tree:add(fds.flags, rang)
	flags_tree:set_text(format('Flags: 0x%02X (%s)', flags, flags_list))
	flags_tree:add(fds.flags_more, rang)
	offset = offset + 1
	if flags_bits.MORE then
		tap.more = tap.more + 1
	else
		-- if the 'more' flag is not set then this is the last frame in a message.
		tap.msgs = tap.msgs + 1
	end
	-- Frame body
	local body_len = frame_len - 1
	local body = ''
	if body_len > 0 then
		tap.body_bytes = tap.body_bytes + body_len
		rang = buffer(offset, body_len)
		local ti = frame_tree:add_le(fds.body, rang)
		if body_len <= 4 then
			body = format("%08x", rang:uint())
		else
			body = tostring(rang)
		end
		ti:set_text(format("%s", body))
	end
	offset = offset + body_len
	-- frame summary
	if body_len > 0 then
		if flags_bits.MORE then
			frame_tree:set_text(format("Frame: [MORE] Body[%u]=%s", body_len, body))
		else
			frame_tree:set_text(format("Frame: Body[%u]=%s", body_len, body))
		end
	else
		if flags_bits.MORE then
			frame_tree:set_text(format("Frame: [MORE] No data"))
		else
			frame_tree:set_text(format("Frame: No data"))
		end
	end
end

local DESEGMENT_ONE_MORE_SEGMENT = 0x0fffffff
local DESEGMENT_UNTIL_FIN        = 0x0ffffffe

-- packet dissector
function zmq_proto.dissector(tvb,pinfo,tree)
	local offset = 0
	local tvb_length = tvb:len()
	local reported_length = tvb:reported_len()
	local length_remaining
	local zmq_tree
	local rang
	local frames = 0
	local tap = {}

	tap.frames = 0
	tap.msgs = 0
	tap.more = 0
	tap.body_bytes = 0

	while(offset < reported_length and offset < tvb_length) do
		length_remaining = tvb_length - offset
		-- check for fixed part of PDU
		if length_remaining < 2 then
			pinfo.desegment_offset = offset
			pinfo.desegment_len = DESEGMENT_ONE_MORE_SEGMENT
			break
		end
		-- decode frame length
			-- decode single byte frame length
		rang = tvb(offset, 1)
		local frame_len = rang:le_uint()
		local pdu_len = frame_len + 1
		if frame_len == 255 then
			-- make sure there is enough bytes
			if length_remaining < 10 then
				pinfo.desegment_offset = offset
				pinfo.desegment_len = DESEGMENT_ONE_MORE_SEGMENT
				break
			end
			-- decode extra long frame length.
			rang = tvb(offset + 1, 8)
			frame_len = tonumber(tostring(rang:uint64()))
			pdu_len = frame_len + 9
		end
		-- provide hints to tcp
		if not pinfo.visited then
			local remaining_bytes = reported_length - offset
			if pdu_len > remaining_bytes then
				pinfo.want_pdu_tracking = 2
				pinfo.bytes_until_next_pdu = pdu_len - remaining_bytes
			end
		end
		-- check if we need more bytes to dissect this frame.
		if length_remaining < pdu_len then
			pinfo.desegment_offset = offset
			pinfo.desegment_len = (pdu_len - length_remaining)
			break
		end
		-- dissect zmq frame
		if not zmq_tree then
			zmq_tree = tree:add(zmq_proto,tvb(),"ZMQ frames")
		end
		rang = tvb(offset, pdu_len)
		local frame_tree = zmq_tree:add(fds.frame, rang)
		zmq_dissect_frame(rang:tvb(), pinfo, frame_tree, tap)
		frames = frames + 1
		-- step to next frame.
		local offset_before = offset
		offset = offset + pdu_len
		if offset < offset_before then break end
	end
	if zmq_tree then
		zmq_tree:set_text(format("ZMQ frames=%u", frames))
	end
	if frames > 0 then
		tap.frames = frames
		pinfo.tap_data = tap
	end
	-- Info column
	pinfo.cols.protocol = "ZMQ"
	pinfo.cols.info = format('ZMQ frames=%u',frames)
end

-- register zmq to handle tcp ports 5550-5560
register_tcp_port_range(5550,5560)

