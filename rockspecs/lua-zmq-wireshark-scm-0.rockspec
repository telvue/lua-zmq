package = "lua-zmq-wireshark"
version = "scm-0"
source = {
	url = "git://github.com/Neopallium/lua-zmq.git",
}
description = {
	summary = "Lua Wireshark dissector for the ZeroMQ protocol.",
	homepage = "http://github.com/Neopallium/lua-zmq",
	-- Wireshark requires dissectors to be licensed under the GPL.
	license = "GPL",
}
dependencies = {}
build = {
	type = "none",
	install = {
		lua = {
			['zmq.ws.dissector'] = "ws/dissector.lua",
			['zmq.ws.tap'] = "ws/tap.lua",
			['zmq.ws.stats_tap'] = "ws/stats_tap.lua",
		},
	},
}
