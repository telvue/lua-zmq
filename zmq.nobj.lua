
c_module "zmq" {
-- module settings.
use_globals = false,
hide_meta_info = true,
luajit_ffi = true,

include "zmq.h",

c_source[[
#define OBJ_UDATA_CTX_SHOULD_FREE (OBJ_UDATA_LAST_FLAG << 1)
]],

--
-- Module constants
--
const "MAX_VSM_SIZE"	{ 30 },

-- message types
const "DELIMITER"			{ 31 },
const "VSM"						{ 32 },

-- message flags
const "MSG_MORE"			{ 1 },
const "MSG_SHARED"		{ 128 },

-- socket types
const "PAIR"					{ 0 },
const "PUB"						{ 1 },
const "SUB"						{ 2 },
const "REQ"						{ 3 },
const "REP"						{ 4 },
const "XREQ"					{ 5 },
const "XREP"					{ 6 },
const "PULL"					{ 7 },
const "PUSH"					{ 8 },

-- socket options
const "HWM"						{ 1 },
const "SWAP"					{ 3 },
const "AFFINITY"			{ 4 },
const "IDENTITY"			{ 5 },
const "SUBSCRIBE"			{ 6 },
const "UNSUBSCRIBE"		{ 7 },
const "RATE"					{ 8 },
const "RECOVERY_IVL"	{ 9 },
const "MCAST_LOOP"		{ 10 },
const "SNDBUF"				{ 11 },
const "RCVBUF"				{ 12 },
const "RCVMORE"				{ 13 },
const "FD"						{ 14 },
const "EVENTS"				{ 15 },
const "TYPE"					{ 16 },
const "LINGER"				{ 17 },
const "RECONNECT_IVL"	{ 18 },
const "BACKLOG"				{ 19 },

-- send/recv flags
const "NOBLOCK"				{ 1 },
const "SNDMORE"				{ 2 },

-- poll events
const "POLLIN"				{ 1 },
const "POLLOUT"				{ 2 },
const "POLLERR"				{ 4 },

-- devices
const "STREAMER"			{ 1 },
const "FORWARDER"			{ 2 },
const "QUEUE"					{ 3 },

--
-- Module static functions
--
c_function "version" {
	var_out{ "<any>", "ver" },
	c_source[[
	int major, minor, patch;
	zmq_version(&(major), &(minor), &(patch));

	/* return version as a table: { major, minor, patch } */
	lua_createtable(L, 3, 0);
	lua_pushinteger(L, major);
	lua_rawseti(L, -2, 1);
	lua_pushinteger(L, minor);
	lua_rawseti(L, -2, 2);
	lua_pushinteger(L, patch);
	lua_rawseti(L, -2, 3);
]]
},
c_function "init" {
	var_in{ "<any>", "io_threads" },
	var_out{ "ZMQ_Ctx", "ctx", own = true },
	var_out{ "ZMQ_Error", "err"},
	c_source[[
	if(lua_isnumber(L, ${io_threads::idx})) {
		${ctx} = zmq_init(lua_tointeger(L,${io_threads::idx}));
		if(${ctx} == NULL) ${err} = -1;
		${ctx}_flags |= OBJ_UDATA_CTX_SHOULD_FREE;
	} else {
		${ctx} = lua_touserdata(L, ${io_threads::idx});
	}
]]
},
c_function "device" {
	c_call "ZMQ_Error" "zmq_device"
		{ "int", "device", "ZMQ_Socket", "insock", "ZMQ_Socket", "outsock" },
},

ffi_files {
"src/zmq_ffi.nobj.lua",
},
subfiles {
"src/zmq_ffi.nobj.lua",
"src/error.nobj.lua",
"src/ctx.nobj.lua",
"src/socket.nobj.lua",
},
}

