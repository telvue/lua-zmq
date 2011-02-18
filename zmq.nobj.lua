
c_module "zmq" {
-- module settings.
use_globals = false,
hide_meta_info = true,

include "zmq.h",

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
	var_out{ "int", "major" },
	var_out{ "int", "minor" },
	var_out{ "int", "patch" },
	c_source[[
	zmq_version(&(${major}), &(${minor}), &(${patch}));
]]
},
c_function "init" {
	var_in{ "int", "io_threads" },
	var_out{ "ZMQ_Ctx", "ctx", own = true },
	var_out{ "ZMQ_Error", "err"},
	c_source[[
	${ctx} = zmq_init(${io_threads});
	if(${ctx} == NULL) ${err} = -1;
]]
},
c_function "device" {
	c_call "ZMQ_Error" "zmq_device" { "int", "device", "ZMQ_Socket", "insock", "ZMQ_Socket", "outsock" },
},

subfiles {
"error.nobj.lua",
"ctx.nobj.lua",
"socket.nobj.lua",
},
}

