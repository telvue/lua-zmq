
set_variable_format "%s"

c_module "zmq" {
-- module settings.
use_globals = false,
hide_meta_info = true,
luajit_ffi = true,

sys_include "string.h",
include "zmq.h",

c_source[[
#define OBJ_UDATA_CTX_SHOULD_FREE (OBJ_UDATA_LAST_FLAG << 1)

static const char *get_zmq_strerror() {
	int err = zmq_errno();
	switch(err) {
	case EAGAIN:
		return "timeout";
		break;
	case ETERM:
		return "closed";
		break;
	default:
		break;
	}
	return zmq_strerror(err);
}

]],

--
-- Module constants
--
constants {
MAX_VSM_SIZE	 = 30,

-- message types
DELIMITER			 = 31,
VSM						 = 32,

-- message flags
MSG_MORE			 = 1,
MSG_SHARED		 = 128,

-- socket types
PAIR					 = 0,
PUB						 = 1,
SUB						 = 2,
REQ						 = 3,
REP						 = 4,
XREQ					 = 5,
XREP					 = 6,
PULL					 = 7,
PUSH					 = 8,

-- socket options
HWM						 = 1,
SWAP					 = 3,
AFFINITY			 = 4,
IDENTITY			 = 5,
SUBSCRIBE			 = 6,
UNSUBSCRIBE		 = 7,
RATE					 = 8,
RECOVERY_IVL	 = 9,
MCAST_LOOP		 = 10,
SNDBUF				 = 11,
RCVBUF				 = 12,
RCVMORE				 = 13,
FD						 = 14,
EVENTS				 = 15,
TYPE					 = 16,
LINGER				 = 17,
RECONNECT_IVL	 = 18,
BACKLOG				 = 19,

-- send/recv flags
NOBLOCK				 = 1,
SNDMORE				 = 2,

-- poll events
POLLIN				 = 1,
POLLOUT				 = 2,
POLLERR				 = 4,

-- devices
STREAMER			 = 1,
FORWARDER			 = 2,
QUEUE					 = 3,
},

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
	var_out{ "ZMQ_Ctx", "!ctx" },
	c_source[[
	if(lua_isnumber(L, ${io_threads::idx})) {
		${ctx} = zmq_init(lua_tointeger(L,${io_threads::idx}));
		${ctx}_flags |= OBJ_UDATA_CTX_SHOULD_FREE;
	} else if(lua_isuserdata(L, ${io_threads::idx})) {
		${ctx} = lua_touserdata(L, ${io_threads::idx});
	} else {
		/* check if value is a LuaJIT 'cdata' */
		int type = lua_type(L, ${io_threads::idx});
		const char *typename = lua_typename(L, type);
		if(strncmp(typename, "cdata", sizeof("cdata")) == 0) {
			${ctx} = (void *)lua_topointer(L, ${io_threads::idx});
		} else {
			return luaL_argerror(L, ${io_threads::idx}, "(expected number)");
		}
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
"src/error.nobj.lua",
"src/ctx.nobj.lua",
"src/socket.nobj.lua",
},
}

