package = "lua-zmq-threads"
version = "scm-0"
source = {
	url = "git://github.com/Neopallium/lua-zmq.git"
}
description = {
	summary = "Lua bindings to zeromq2, with LuaJIT2 FFI support.",
	homepage = "http://github.com/Neopallium/lua-zmq",
	license = "MIT/X11"
}
dependencies = {
	"lua >= 5.1",
	"zmq",
}
build = {
	type = "builtin",
	install = {
		lua = {
			['zmq.threads'] = "src/threads.lua",
		}
	}
}
