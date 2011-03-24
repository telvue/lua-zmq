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

local ZMQ_Thread_type = [[
typedef enum {
	TSTATE_NONE     = 0,
	TSTATE_STARTED  = 1<<1,
	TSTATE_DETACHED = 1<<2,
	TSTATE_JOINED   = 1<<3,
} ZMQ_TState;

typedef struct ZMQ_Thread {
	lua_State  *L;
	pthread_t  thread;
	ZMQ_TState state;
	int        nargs;
	int        status;
} ZMQ_Thread;

]]
object "ZMQ_Thread" {
	sys_include "pthread.h",
	c_source(ZMQ_Thread_type),
	c_source[[

#include <stdio.h>

/* traceback() function from Lua 5.1.x source. */
static int traceback (lua_State *L) {
  if (!lua_isstring(L, 1))  /* 'message' not a string? */
    return 1;  /* keep it intact */
  lua_getfield(L, LUA_GLOBALSINDEX, "debug");
  if (!lua_istable(L, -1)) {
    lua_pop(L, 1);
    return 1;
  }
  lua_getfield(L, -1, "traceback");
  if (!lua_isfunction(L, -1)) {
    lua_pop(L, 2);
    return 1;
  }
  lua_pushvalue(L, 1);  /* pass error message */
  lua_pushinteger(L, 2);  /* skip this function and traceback */
  lua_call(L, 2, 1);  /* call debug.traceback */
  return 1;
}

static ZMQ_Thread *thread_new() {
	ZMQ_Thread *this;

	this = (ZMQ_Thread *)calloc(1, sizeof(ZMQ_Thread));
	this->state = TSTATE_NONE;
	/* create new lua_State for the thread. */
	this->L = luaL_newstate();
	/* open standard libraries. */
	luaL_openlibs(this->L);
	/* push traceback function as first value on stack. */
	lua_pushcfunction(this->L, traceback);

	return this;
}

static void thread_destroy(ZMQ_Thread *this) {
	lua_close(this->L);
	free(this);
}

static void *run_child_thread(void *arg) {
	ZMQ_Thread *this = (ZMQ_Thread *)arg;
	lua_State *L = this->L;

	this->status = lua_pcall(L, this->nargs, 0, 1);

	if(this->status != 0) {
		const char *err_msg = lua_tostring(L, -1);
		fprintf(stderr, "%s\n", err_msg);
		fflush(stderr);
	}

	return NULL;
}

static int thread_start(ZMQ_Thread *this, int start_detached) {
	int rc;

	this->state = TSTATE_STARTED | ((start_detached) ? TSTATE_DETACHED : 0);
	rc = pthread_create(&(this->thread), NULL, run_child_thread, this);
	if(rc != 0) return rc;
	if(start_detached) {
		rc = pthread_detach(this->thread);
	}
	return rc;
}

]],
	constructor {
		var_in{ "const char *", "bootstrap_code" },
		--[[ varargs(...) ]]
		c_source "pre" [[
	const char *str;
	size_t str_len;
	int nargs = 0;
	int rc;
	int top;
	int n;
]],
		c_source[[
	${this} = thread_new();
	/* load bootstrap Lua code into child state. */
	rc = luaL_loadbuffer(${this}->L, ${bootstrap_code}, ${bootstrap_code_len}, ${bootstrap_code});
	if(rc != 0) {
		/* copy error message to parent state. */
		str = lua_tolstring(${this}->L, -1, &(str_len));
		if(str != NULL) {
			lua_pushlstring(L, str, str_len);
		} else {
			/* non-string error message. */
			lua_pushfstring(L, "luaL_loadbuffer() failed to luad bootstrap code: rc=%d", rc);
		}
		thread_destroy(${this});
		return lua_error(L);
	}
	/* copy extra args from main state to child state. */
	top = lua_gettop(L);
	/* skip the bootstrap code. */
	for(n = ${bootstrap_code::idx} + 1; n <= top; n++) {
		/* only support string/number/boolean/nil/lightuserdata. */
		switch(lua_type(L, n)) {
		case LUA_TNIL:
			lua_pushnil(${this}->L);
			break;
		case LUA_TNUMBER:
			lua_pushnumber(${this}->L, lua_tonumber(L, n));
			break;
		case LUA_TBOOLEAN:
			lua_pushboolean(${this}->L, lua_toboolean(L, n));
			break;
		case LUA_TSTRING:
			str = lua_tolstring(L, n, &(str_len));
			lua_pushlstring(${this}->L, str, str_len);
			break;
		case LUA_TLIGHTUSERDATA:
			lua_pushlightuserdata(${this}->L, lua_touserdata(L, n));
			break;
		case LUA_TTABLE:
		case LUA_TFUNCTION:
		case LUA_TUSERDATA:
		case LUA_TTHREAD:
		default:
			return luaL_argerror(L, n,
				"Only nil/number/boolean/string/lightuserdata values are supported");
		}
		++nargs;
	}
	${this}->nargs = nargs;
]]
	},
	destructor {
		c_source[[
	/* We still own the thread object iff the thread was not started or we have joined the thread. */
	if(${this}->state == TSTATE_NONE || ${this}->state == TSTATE_JOINED) {
		thread_destroy(${this});
	}
]]
	},
	method "start" {
		var_in{ "bool", "start_detached", is_optional = true, default = 0 },
		var_out{ "int", "rc" },
		c_source[[
	if(${this}->state != TSTATE_NONE) {
		return luaL_error(L, "Thread already started.");
	}
	${rc} = thread_start(${this}, ${start_detached});
]]
	},
	method "join" {
		var_out{ "int", "rc" },
		c_source[[
	if((${this}->state & TSTATE_STARTED) == 0) {
		return luaL_error(L, "Can't join a thread that hasn't be started.");
	}
	${rc} = pthread_join(${this}->thread, NULL);
	/* now we own the thread object again. */
	${this}->state = TSTATE_JOINED;
]]
	},
}

