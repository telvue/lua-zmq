ffi_source "ffi_src" [==================[
local zmq = ...

-- try loading luajit's ffi
local stat, ffi=pcall(require,"ffi")
if not stat then
	print("No FFI module: ZMQ using standard Lua api interface.")
	return
end
-- check if ffi is disabled.
if disable_ffi then
	print("FFI disabled: ZMQ using standard Lua api interface.")
	return
end

local setmetatable = setmetatable
local print = print
local pairs = pairs
local error = error
local type = type
local assert = assert
local tostring = tostring
local tonumber = tonumber

local z_SUBSCRIBE = zmq.SUBSCRIBE
local z_UNSUBSCRIBE = zmq.UNSUBSCRIBE
local z_IDENTITY = zmq.IDENTITY
local z_NOBLOCK = zmq.NOBLOCK
local z_RCVMORE = zmq.RCVMORE
local z_SNDMORE = zmq.SNDMORE
local z_EVENTS = zmq.EVENTS
local z_POLLIN = zmq.POLLIN
local z_POLLOUT = zmq.POLLOUT
local z_POLLIN_OUT = z_POLLIN + z_POLLOUT

ffi.cdef[[
void zmq_version (int *major, int *minor, int *patch);
int zmq_errno ();
const char *zmq_strerror (int errnum);

typedef struct zmq_msg_t
{
    void *content;
    unsigned char flags;
    unsigned char vsm_size;
    unsigned char vsm_data [30];
} zmq_msg_t;

typedef void (zmq_free_fn) (void *data, void *hint);

int zmq_msg_init (zmq_msg_t *msg);
int zmq_msg_init_size (zmq_msg_t *msg, size_t size);
int zmq_msg_init_data (zmq_msg_t *msg, void *data, size_t size, zmq_free_fn *ffn, void *hint);
int zmq_msg_close (zmq_msg_t *msg);
int zmq_msg_move (zmq_msg_t *dest, zmq_msg_t *src);
int zmq_msg_copy (zmq_msg_t *dest, zmq_msg_t *src);
void *zmq_msg_data (zmq_msg_t *msg);
size_t zmq_msg_size (zmq_msg_t *msg);

void *zmq_init (int io_threads);
int zmq_term (void *context);

void *zmq_socket (void *context, int type);
int zmq_close (void *s);
int zmq_setsockopt (void *s, int option, const void *optval, size_t optvallen);
int zmq_getsockopt (void *s, int option, void *optval, size_t *optvallen);
int zmq_bind (void *s, const char *addr);
int zmq_connect (void *s, const char *addr);
int zmq_send (void *s, zmq_msg_t *msg, int flags);
int zmq_recv (void *s, zmq_msg_t *msg, int flags);

int zmq_device (int device, void * insocket, void* outsocket);

]]

require"utils"
local C = ffi.load"zmq"

--module(...)
zmq._M = zmq
setfenv(1, zmq)

function version()
	local major = ffi.new('int[1]',0)
	local minor = ffi.new('int[1]',0)
	local patch = ffi.new('int[1]',0)
	C.zmq_version(major, minor, patch)
	return {major[0], minor[0], patch[0]}
end

local function zmq_error()
	local errno = C.zmq_errno()
	local err = ffi.string(C.zmq_strerror(errno))
	if err == "Resource temporarily unavailable" then err = "timeout" end
	if err == "Context was terminated" then err = "closed" end
	return nil, err
end

--
-- ZMQ socket
--
local sock_mt = {}
sock_mt.__index = sock_mt

local function new_socket(ctx, sock_type)
	local sock = C.zmq_socket(ctx, sock_type)
	if not sock then
		return zmq_error()
	end
	return setmetatable({ sock = sock }, sock_mt)
end

function sock_mt:close()
	local ret = C.zmq_close(self.sock)
	self.sock = nil
	if ret ~= 0 then
		return zmq_error()
	end
	return true
end

local option_types = {
[zmq.HWM] = 'uint64_t[1]',
[zmq.SWAP] = 'int64_t[1]',
[zmq.AFFINITY] = 'uint64_t[1]',
[zmq.IDENTITY] = 'string',
[zmq.SUBSCRIBE] = 'string',
[zmq.UNSUBSCRIBE] = 'string',
[zmq.RATE] = 'int64_t[1]',
[zmq.RECOVERY_IVL] = 'int64_t[1]',
[zmq.MCAST_LOOP] = 'int64_t[1]',
[zmq.SNDBUF] = 'uint64_t[1]',
[zmq.RCVBUF] = 'uint64_t[1]',
[zmq.RCVMORE] = 'int64_t[1]',
[zmq.FD] = 'int[1]',
[zmq.EVENTS] = 'uint32_t[1]',
[zmq.TYPE] = 'int[1]',
[zmq.LINGER] = 'int[1]',
[zmq.RECONNECT_IVL] = 'int[1]',
[zmq.BACKLOG] = 'int[1]',
}
local option_len = {}
local option_tmps = {}
for k,v in pairs(option_types) do
	if v ~= 'string' then
		option_len[k] = ffi.sizeof(v)
		option_tmps[k] = ffi.new(v, 0)
	end
end
function sock_mt:setopt(opt, opt_val)
	local ctype = option_types[opt]
	local val_len = 0
	if ctype == 'string' then
		--val = ffi.cast('void *', tostring(val))
		val = tostring(opt_val)
		val_len = #val
	else
		val = option_tmps[opt]
		val[0] = opt_val
		val_len = option_len[opt]
	end
	local ret = C.zmq_setsockopt(self.sock, opt, val, val_len)
	if ret ~= 0 then
		return zmq_error()
	end
	return true
end

local tmp_val_len = ffi.new('size_t[1]', 4)
function sock_mt:getopt(opt)
	local ctype = option_types[opt]
	local val
	local val_len = tmp_val_len
	if ctype == 'string' then
		val_len[0] = 255
		val = ffi.new('uint8_t[?]', val_len[0])
		ffi.fill(val, val_len[0])
	else
		val = option_tmps[opt]
		val[0] = 0
		val_len[0] = option_len[opt]
	end
	local ret = C.zmq_getsockopt(self.sock, opt, val, val_len)
	if ret ~= 0 then
		return zmq_error()
	end
	if ctype == 'string' then
		val_len = val_len[0]
		return ffi.string(val, val_len)
	else
		val = val[0]
	end
	return tonumber(val)
end

local tmp32 = ffi.new('uint32_t[1]', 0)
local tmp32_len = ffi.new('size_t[1]', 4)
function sock_mt:events()
	local val = tmp32
	local val_len = tmp32_len
	val[0] = 0
	val_len[0] = 4
	local ret = C.zmq_getsockopt(self.sock, 15, val, val_len)
	if ret ~= 0 then
		return zmq_error()
	end
	return val[0]
end

function sock_mt:bind(addr)
	local ret = C.zmq_bind(self.sock, addr)
	if ret ~= 0 then
		return zmq_error()
	end
	return true
end

function sock_mt:connect(addr)
	local ret = C.zmq_connect(self.sock, addr)
	if ret ~= 0 then
		return zmq_error()
	end
	return true
end

local tmp_msg = ffi.new('zmq_msg_t')
function sock_mt:send(data, flags)
	local msg = tmp_msg
	local msg_len = #data
	-- initialize message
	if C.zmq_msg_init_size(msg, msg_len) < 0 then
		return zmq_error()
	end
	-- copy data into message.
	ffi.copy(C.zmq_msg_data(msg), data, msg_len)

	-- send message
	local ret = C.zmq_send(self.sock, msg, flags or 0)
	-- close message before processing return code
	C.zmq_msg_close(msg)
	-- now process send return code
	if ret ~= 0 then
		return zmq_error()
	end
	return true
end

function sock_mt:recv(flags)
	local msg = tmp_msg
	-- initialize blank message.
	if C.zmq_msg_init(msg) < 0 then
		return zmq_error()
	end

	-- receive message
	local ret = C.zmq_recv(self.sock, msg, flags or 0)
	if ret ~= 0 then
		local data, err = zmq_error()
		C.zmq_msg_close(msg)
		return data, err
	end
	local data = ffi.string(C.zmq_msg_data(msg), C.zmq_msg_size(msg))
	-- close message
	C.zmq_msg_close(msg)
	return data
end

--
-- ZMQ context
--
local ctx_mt = {}
ctx_mt.__index = ctx_mt

function ctx_mt:term()
	if C.zmq_term(self.ctx) ~= 0 then
		return zmq_error()
	end
	return true
end

function ctx_mt:socket(sock_type)
	return new_socket(self.ctx, sock_type)
end

function init(io_threads)
	print("ZMQ using FFI interface.")
	local ctx = C.zmq_init(io_threads)
	if not ctx then
		return zmq_error()
	end
	return setmetatable({ ctx = ctx }, ctx_mt)
end

]==================]
