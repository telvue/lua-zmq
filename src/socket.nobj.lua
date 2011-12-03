-- Copyright (c) 2011 by Robert G. Jakabosky <bobby@sharedrealm.com>
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

object "ZMQ_Socket" {
	error_on_null = "get_zmq_strerror()",
	c_source [[
/* detect zmq version */
#define VERSION_2_0 1
#define VERSION_2_1 0
#define VERSION_3_0 0
#if defined(ZMQ_VERSION)
#  if (ZMQ_VERSION >= ZMQ_MAKE_VERSION(2,1,0))
#    undef VERSION_2_1
#    define VERSION_2_1 1
#  endif
#  if (ZMQ_VERSION >= ZMQ_MAKE_VERSION(3,0,0))
#    undef VERSION_2_0
#    define VERSION_2_0 0
#    undef VERSION_3_0
#    define VERSION_3_0 1
#  endif
#endif

/* detect really old ZeroMQ 2.0.x series. */
#if !defined(ZMQ_RCVMORE)
#  error "Your version of ZeroMQ is too old.  Please upgrade to version 2.1 or to the latest 2.0.x"
#endif

typedef struct ZMQ_Socket ZMQ_Socket;

#ifdef _WIN32
#include <winsock2.h>
typedef SOCKET socket_t;
#else
typedef int socket_t;
#endif

#if ZMQ_VERSION_MAJOR == 2
#  define zmq_sendmsg      zmq_send
#  define zmq_recvmsg      zmq_recv
#endif

/* socket option types. */
#define OPT_TYPE_NONE		0
#define OPT_TYPE_INT		1
#define OPT_TYPE_UINT32	2
#define OPT_TYPE_UINT64	3
#define OPT_TYPE_INT64	4
#define OPT_TYPE_BLOB		5
#define OPT_TYPE_FD			6

static const int opt_types[] = {
#if VERSION_3_0
  OPT_TYPE_NONE,    /*  0 unused */
  OPT_TYPE_INT,     /*  1 ZMQ_HWM for backwards compatibility */
  OPT_TYPE_NONE,    /*  2 unused */
  OPT_TYPE_NONE,    /*  3 unused */
  OPT_TYPE_UINT64,  /*  4 ZMQ_AFFINITY */
  OPT_TYPE_BLOB,    /*  5 ZMQ_IDENTITY */
  OPT_TYPE_BLOB,    /*  6 ZMQ_SUBSCRIBE */
  OPT_TYPE_BLOB,    /*  7 ZMQ_UNSUBSCRIBE */
  OPT_TYPE_INT,     /*  8 ZMQ_RATE */
  OPT_TYPE_INT,     /*  9 ZMQ_RECOVERY_IVL */
  OPT_TYPE_INT,     /* 10 ZMQ_MCAST_LOOP */
  OPT_TYPE_INT,     /* 11 ZMQ_SNDBUF */
  OPT_TYPE_INT,     /* 12 ZMQ_RCVBUF */
  OPT_TYPE_INT,     /* 13 ZMQ_RCVMORE */
  OPT_TYPE_FD,      /* 14 ZMQ_FD */
  OPT_TYPE_INT,     /* 15 ZMQ_EVENTS */
  OPT_TYPE_INT,     /* 16 ZMQ_TYPE */
  OPT_TYPE_INT,     /* 17 ZMQ_LINGER */
  OPT_TYPE_INT,     /* 18 ZMQ_RECONNECT_IVL */
  OPT_TYPE_INT,     /* 19 ZMQ_BACKLOG */
  OPT_TYPE_NONE,    /* 20 unused */
  OPT_TYPE_INT,     /* 21 ZMQ_RECONNECT_IVL_MAX */
  OPT_TYPE_INT64,   /* 22 ZMQ_MAXMSGSIZE */
  OPT_TYPE_INT,     /* 23 ZMQ_SNDHWM */
  OPT_TYPE_INT,     /* 24 ZMQ_RCVHWM */
  OPT_TYPE_INT,     /* 25 ZMQ_MULTICAST_HOPS */
  OPT_TYPE_NONE,    /* 26 unused */
  OPT_TYPE_INT,     /* 27 ZMQ_RCVTIMEO */
  OPT_TYPE_INT,     /* 28 ZMQ_SNDTIMEO */
  OPT_TYPE_INT,     /* 29 ZMQ_RCVLABEL */
# define MAX_OPTS 29
#else
  /* options for versions below 3.0 */
  OPT_TYPE_NONE,    /*  0 unused */
  OPT_TYPE_UINT64,  /*  1 ZMQ_HWM */
  OPT_TYPE_NONE,    /*  2 unused */
  OPT_TYPE_INT64,   /*  3 ZMQ_SWAP */
  OPT_TYPE_UINT64,  /*  4 ZMQ_AFFINITY */
  OPT_TYPE_BLOB,    /*  5 ZMQ_IDENTITY */
  OPT_TYPE_BLOB,    /*  6 ZMQ_SUBSCRIBE */
  OPT_TYPE_BLOB,    /*  7 ZMQ_UNSUBSCRIBE */
  OPT_TYPE_INT64,   /*  8 ZMQ_RATE */
  OPT_TYPE_INT64,   /*  9 ZMQ_RECOVERY_IVL */
  OPT_TYPE_INT64,   /* 10 ZMQ_MCAST_LOOP */
  OPT_TYPE_UINT64,  /* 11 ZMQ_SNDBUF */
  OPT_TYPE_UINT64,  /* 12 ZMQ_RCVBUF */
  OPT_TYPE_INT64,   /* 13 ZMQ_RCVMORE */

#  if VERSION_2_1
  OPT_TYPE_FD,      /* 14 ZMQ_FD */
  OPT_TYPE_UINT32,  /* 15 ZMQ_EVENTS */
  OPT_TYPE_INT,     /* 16 ZMQ_TYPE */
  OPT_TYPE_INT,     /* 17 ZMQ_LINGER */
  OPT_TYPE_INT,     /* 18 ZMQ_RECONNECT_IVL */
  OPT_TYPE_INT,     /* 19 ZMQ_BACKLOG */
  OPT_TYPE_INT64,   /* 20 ZMQ_RECOVERY_IVL_MSEC */
  OPT_TYPE_INT,     /* 21 ZMQ_RECONNECT_IVL_MAX */
#    define MAX_OPTS 21
#  else
#    define MAX_OPTS 13
#  endif
#endif

};

]],

	destructor "close" {
		c_method_call "ZMQ_Error"  "zmq_close" {}
	},
	method "bind" {
		c_method_call "ZMQ_Error"  "zmq_bind" { "const char *", "addr" }
	},
	method "connect" {
		c_method_call "ZMQ_Error"  "zmq_connect" { "const char *", "addr" }
	},
	ffi_cdef[[
int zmq_setsockopt (void *s, int option, const void *optval, size_t optvallen);
int zmq_getsockopt (void *s, int option, void *optval, size_t *optvallen);
]],
	ffi_source[[
local option_len = {}
local option_types = {}
local option_tmps

do
	local zmq = _M
	local zver = zmq.version()

	local str_opt_temp_len = 255
	option_tmps = setmetatable({}, {__index = function(tab, ctype)
		local temp
		if ctype == 'string' then
			tmp = ffi.new('uint8_t[?]', str_opt_temp_len)
		else
			tmp = ffi.new(ctype, 0)
		end
		rawset(tab, ctype, tmp)
		return tmp
	end})

	local function def_opt(opt, ctype)
		if not opt then return end
		option_types[opt] = ctype
		if ctype == 'string' then
			option_len[opt] = str_opt_temp_len
		else
			option_len[opt] = ffi.sizeof(ctype)
		end
	end

	if zver[1] == 2 then
		def_opt(zmq.HWM,               'uint64_t[1]')
		def_opt(zmq.SWAP,              'int64_t[1]')
		def_opt(zmq.AFFINITY,          'uint64_t[1]')
		def_opt(zmq.IDENTITY,          'string')
		def_opt(zmq.SUBSCRIBE,         'string')
		def_opt(zmq.UNSUBSCRIBE,       'string')
		def_opt(zmq.RATE,              'int64_t[1]')
		def_opt(zmq.RECOVERY_IVL,      'int64_t[1]')
		def_opt(zmq.RECOVERY_IVL_MSEC, 'int64_t[1]')
		def_opt(zmq.MCAST_LOOP,        'int64_t[1]')
		def_opt(zmq.SNDBUF,            'uint64_t[1]')
		def_opt(zmq.RCVBUF,            'uint64_t[1]')
		def_opt(zmq.RCVMORE,           'int64_t[1]')
		def_opt(zmq.FD,                'int[1]')
		def_opt(zmq.EVENTS,            'uint32_t[1]')
		def_opt(zmq.TYPE,              'int[1]')
		def_opt(zmq.LINGER,            'int[1]')
		def_opt(zmq.RECONNECT_IVL,     'int[1]')
		def_opt(zmq.BACKLOG,           'int[1]')
		def_opt(zmq.RECONNECT_IVL_MAX, 'int[1]')
	elseif zver[1] == 3 then
		def_opt(zmq.AFFINITY,          'uint64_t[1]')
		def_opt(zmq.IDENTITY,          'string')
		def_opt(zmq.SUBSCRIBE,         'string')
		def_opt(zmq.UNSUBSCRIBE,       'string')
		def_opt(zmq.RATE,              'int[1]')
		def_opt(zmq.RECOVERY_IVL,      'int[1]')
		def_opt(zmq.RECOVERY_IVL_MSEC, 'int[1]')
		def_opt(zmq.MCAST_LOOP,        'int[1]')
		def_opt(zmq.SNDBUF,            'int[1]')
		def_opt(zmq.RCVBUF,            'int[1]')
		def_opt(zmq.RCVMORE,           'int[1]')
		def_opt(zmq.FD,                'int[1]')
		def_opt(zmq.EVENTS,            'int[1]')
		def_opt(zmq.TYPE,              'int[1]')
		def_opt(zmq.LINGER,            'int[1]')
		def_opt(zmq.RECONNECT_IVL,     'int[1]')
		def_opt(zmq.BACKLOG,           'int[1]')
		def_opt(zmq.RECONNECT_IVL_MAX, 'int[1]')
		def_opt(zmq.MAXMSGSIZE,        'int64_t[1]')
		def_opt(zmq.SNDHWM,            'int[1]')
		def_opt(zmq.RCVHWM,            'int[1]')
		def_opt(zmq.MULTICAST_HOPS,    'int[1]')
		def_opt(zmq.RCVTIMEO,          'int[1]')
		def_opt(zmq.SNDTIMEO,          'int[1]')
		def_opt(zmq.RCVLABEL,          'int[1]')
	end
end

]],
	method "setopt" {
		var_in{ "uint32_t", "opt" },
		var_in{ "<any>", "val" },
		var_out{ "ZMQ_Error", "err" },
		c_source[[
	size_t val_len;
	const void *val;

#if VERSION_2_1
	socket_t fd_val;
#endif
	int int_val;
	uint32_t uint32_val;
	uint64_t uint64_val;
	int64_t int64_val;

#if VERSION_3_0
	/* 3.0 backwards compatibility support for HWM. */
	if(${opt} == ZMQ_HWM) {
		int_val = luaL_checklong(L, ${val::idx});
		val = &int_val;
		val_len = sizeof(int_val);
		${err} = zmq_setsockopt(${this}, ZMQ_SNDHWM, val, val_len);
		if(-1 != ${err}) {
			${err} = zmq_setsockopt(${this}, ZMQ_RCVHWM, val, val_len);
		}
		goto finished;
	}
#endif

	if(${opt} > MAX_OPTS) {
		return luaL_argerror(L, ${opt::idx}, "Invalid socket option.");
	}

	switch(opt_types[${opt}]) {
#if VERSION_2_1
	case OPT_TYPE_FD:
		fd_val = luaL_checklong(L, ${val::idx});
		val = &fd_val;
		val_len = sizeof(fd_val);
		break;
#endif
	case OPT_TYPE_INT:
		int_val = luaL_checklong(L, ${val::idx});
		val = &int_val;
		val_len = sizeof(int_val);
		break;
	case OPT_TYPE_UINT32:
		uint32_val = luaL_checklong(L, ${val::idx});
		val = &uint32_val;
		val_len = sizeof(uint32_val);
		break;
	case OPT_TYPE_UINT64:
		uint64_val = luaL_checklong(L, ${val::idx});
		val = &uint64_val;
		val_len = sizeof(uint64_val);
		break;
	case OPT_TYPE_INT64:
		int64_val = luaL_checklong(L, ${val::idx});
		val = &int64_val;
		val_len = sizeof(int64_val);
		break;
	case OPT_TYPE_BLOB:
		val = luaL_checklstring(L, ${val::idx}, &(val_len));
		break;
	default:
		printf("Invalid socket option type, this shouldn't happen.\n");
		abort();
		break;
	}
	${err} = zmq_setsockopt(${this}, ${opt}, val, val_len);
finished:
]],
		ffi_source[[
	local ctype = option_types[${opt}]
	local tval
	local tval_len = 0
	if ctype then
		if ctype == 'string' then
			tval = tostring(${val})
			tval_len = #tval
		else
			tval = option_tmps[ctype]
			tval[0] = ${val}
			tval_len = option_len[${opt}]
		end
		${err} = C.zmq_setsockopt(${this}, ${opt}, tval, tval_len)
	elseif ${opt} == zmq.HWM then
		-- 3.0 backwards compatibility support for HWM.
		ctype = option_types[zmq.SNDHWM]
		tval = option_tmps[ctype]
		tval[0] = ${val}
		tval_len = option_len[zmq.SNDHWM]
		${err} = C.zmq_setsockopt(${this}, zmq.SNDHWM, tval, tval_len)
		if (-1 ~= ${err}) then
			${err} = C.zmq_setsockopt(${this}, zmq.RCVHWM, tval, tval_len)
		end
	else
		error("Invalid socket option.")
	end
]],
	},
		ffi_source[[
local tmp_val_len = ffi.new('size_t[1]', 4)
]],
	method "getopt" {
		var_in{ "uint32_t", "opt" },
		var_out{ "<any>", "val" },
		var_out{ "ZMQ_Error", "err" },
		c_source[[
	size_t val_len;

#if VERSION_2_1
	socket_t fd_val;
#endif
	int int_val;
	uint32_t uint32_val;
	uint64_t uint64_val;
	int64_t int64_val;
#define STR_MAX 255
	char str_val[STR_MAX];

	if(${opt} > MAX_OPTS) {
		lua_pushnil(L);
		lua_pushliteral(L, "Invalid socket option.");
		return 2;
	}

	switch(opt_types[${opt}]) {
#if VERSION_2_1
	case OPT_TYPE_FD:
		val_len = sizeof(fd_val);
		${err} = zmq_getsockopt(${this}, ${opt}, &fd_val, &val_len);
		if(0 == ${err}) {
			lua_pushinteger(L, (lua_Integer)fd_val);
			return 1;
		}
		break;
#endif
	case OPT_TYPE_INT:
		val_len = sizeof(int_val);
		${err} = zmq_getsockopt(${this}, ${opt}, &int_val, &val_len);
		if(0 == ${err}) {
			lua_pushinteger(L, (lua_Integer)int_val);
			return 1;
		}
		break;
	case OPT_TYPE_UINT32:
		val_len = sizeof(uint32_val);
		${err} = zmq_getsockopt(${this}, ${opt}, &uint32_val, &val_len);
		if(0 == ${err}) {
			lua_pushinteger(L, (lua_Integer)uint32_val);
			return 1;
		}
		break;
	case OPT_TYPE_UINT64:
		val_len = sizeof(uint64_val);
		${err} = zmq_getsockopt(${this}, ${opt}, &uint64_val, &val_len);
		if(0 == ${err}) {
			lua_pushinteger(L, (lua_Integer)uint64_val);
			return 1;
		}
		break;
	case OPT_TYPE_INT64:
		val_len = sizeof(int64_val);
		${err} = zmq_getsockopt(${this}, ${opt}, &int64_val, &val_len);
		if(0 == ${err}) {
			lua_pushinteger(L, (lua_Integer)int64_val);
			return 1;
		}
		break;
	case OPT_TYPE_BLOB:
		val_len = STR_MAX;
		${err} = zmq_getsockopt(${this}, ${opt}, str_val, &val_len);
		if(0 == ${err}) {
			lua_pushlstring(L, str_val, val_len);
			return 1;
		}
#undef STR_MAX
		break;
	default:
		printf("Invalid socket option type, this shouldn't happen.\n");
		abort();
		break;
	}
	lua_pushnil(L);
]],
		ffi_source[[
	local ctype = option_types[${opt}]
	local val
	local val_len
	if ctype then
		val = option_tmps[ctype]
		val_len = option_len[${opt}]
		${err} = C.zmq_getsockopt(${this}, ${opt}, val, tmp_val_len)
	end
	if ${err} == 0 then
		if ctype == 'string' then
			return ffi.string(val, tmp_val_len[0])
		else
			return tonumber(val[0])
		end
	end
]],
	},
	ffi_source[[
local ZMQ_EVENTS = _M.EVENTS
-- temp. values for 'events' function.
local events_ctype = option_types[ZMQ_EVENTS]
local events_tmp = option_tmps[events_ctype]
local events_tmp_len = option_len[ZMQ_EVENTS]
local events_tmp_size = ffi.sizeof(events_tmp)
]],
	method "events" {
		var_out{ "uint32_t", "events" },
		var_out{ "ZMQ_Error", "err" },
		c_source[[
#if VERSION_3_0
	int val;
	size_t val_len = sizeof(val);
	${err} = zmq_getsockopt(${this}, ZMQ_EVENTS, &val, &val_len);
	${events} = val;
#else
#  if VERSION_2_1
	size_t val_len = sizeof(${events});
	${err} = zmq_getsockopt(${this}, ZMQ_EVENTS, &(${events}), &val_len);
#  else
	luaL_error(L, "'events' method only supported in 0MQ version >= 2.1");
#  endif
#endif
]],
		ffi_source[[
	events_tmp_len[0] = events_tmp_size
	${err} = C.zmq_getsockopt(${this}, ZMQ_EVENTS, events_tmp, events_tmp_len);
	${events} = events_tmp[0]
]],
	},
	--
	-- zmq_send
	--
	method "send_msg" {
		c_export_method_call "ZMQ_Error" "zmq_sendmsg" { "zmq_msg_t *", "msg", "int", "flags?" },
	},
	-- create helper function for `zmq_send`
	c_source[[
ZMQ_Error simple_zmq_send(ZMQ_Socket *sock, const char *data, size_t data_len, int flags) {
	ZMQ_Error err;
	zmq_msg_t msg;
	/* initialize message */
	err = zmq_msg_init_size(&msg, data_len);
	if(0 == err) {
		/* fill message */
		memcpy(zmq_msg_data(&msg), data, data_len);
		/* send message */
		err = zmq_sendmsg(sock, &msg, flags);
		/* close message */
		zmq_msg_close(&msg);
	}
	return err;
}
]],
	method "send" {
		c_method_call "ZMQ_Error" "simple_zmq_send"
			{ "const char *", "data", "size_t", "#data", "int", "flags?"}
	},
	--
	-- zmq_recv
	--
	method "recv_msg" {
		c_export_method_call "ZMQ_Error" "zmq_recvmsg" { "zmq_msg_t *", "msg", "int", "flags?" },
	},
	ffi_source[[
local tmp_msg = ffi.new('zmq_msg_t')
]],
	method "recv" {
		var_in{ "int", "flags?" },
		var_out{ "const char *", "data", has_length = true },
		var_out{ "ZMQ_Error", "err" },
		c_source[[
	zmq_msg_t msg;
	/* initialize message */
	${err} = zmq_msg_init(&msg);
	if(0 == ${err}) {
		/* receive message */
		${err} = zmq_recvmsg(${this}, &msg, ${flags});
		if(0 == ${err}) {
			${data} = zmq_msg_data(&msg);
			${data_len} = zmq_msg_size(&msg);
		}
	}
]],
		c_source "post" [[
	/* close message */
	zmq_msg_close(&msg);
]],
		ffi_source[[
	local msg = tmp_msg
	-- initialize blank message.
	if C.zmq_msg_init(msg) < 0 then
		return nil, get_zmq_strerror()
	end

	-- receive message
	${err} = zmq_recvmsg(${this}, msg, ${flags})
	if 0 == ${err} then
		local data = ffi.string(C.zmq_msg_data(msg), C.zmq_msg_size(msg))
		-- close message
		C.zmq_msg_close(msg)
		return data
	end
]],
		ffi_source "ffi_post" [[
	-- close message
	C.zmq_msg_close(msg)
]],
	},
}

