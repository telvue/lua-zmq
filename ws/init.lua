
local prequire = function(name)
	local status, result1 = pcall(require, name)
	if not status then
		debug("Failed to load " .. name .. ": " .. result1)
	end
	return result1
end

prequire("zmq.ws.dissector")

-- if running from wireshark, register all taps.
if gui_enabled() then
	prequire("zmq.ws.stats_tap")
end

