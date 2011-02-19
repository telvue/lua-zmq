/***********************************************************************************************
************************************************************************************************
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!! Warning this file was generated from a set of *.nobj.lua definition files !!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
************************************************************************************************
***********************************************************************************************/

#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

#include "zmq.h"


#define REG_PACKAGE_IS_CONSTRUCTOR 0
#define REG_OBJECTS_AS_GLOBALS 0
#define OBJ_DATA_HIDDEN_METATABLE 1
#define LUAJIT_FFI 1
#define USE_FIELD_GET_SET_METHODS 0



#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#define FUNC_UNUSED __attribute__((unused))

#if defined(__GNUC__) && (__GNUC__ >= 4)
#define assert_obj_type(type, obj) \
	assert(__builtin_types_compatible_p(typeof(obj), type *))
#else
#define assert_obj_type(type, obj)
#endif

#ifndef obj_type_free
#define obj_type_free(type, obj) do { \
	assert_obj_type(type, obj); \
	free((obj)); \
} while(0)
#endif

#ifndef obj_type_new
#define obj_type_new(type, obj) do { \
	assert_obj_type(type, obj); \
	(obj) = malloc(sizeof(type)); \
} while(0)
#endif

typedef struct obj_type obj_type;

typedef void (*base_caster_t)(void **obj);

typedef void (*dyn_caster_t)(void **obj, obj_type **type);

#define OBJ_TYPE_FLAG_WEAK_REF (1<<0)
#define OBJ_TYPE_SIMPLE (1<<1)
struct obj_type {
	dyn_caster_t    dcaster;  /**< caster to support casting to sub-objects. */
	int32_t         id;       /**< type's id. */
	uint32_t        flags;    /**< type's flags (weak refs) */
	const char      *name;    /**< type's object name. */
};

typedef struct obj_base {
	int32_t        id;
	base_caster_t  bcaster;
} obj_base;

typedef enum obj_const_type {
	CONST_UNKOWN    = 0,
	CONST_BOOLEAN   = 1,
	CONST_NUMBER    = 2,
	CONST_STRING    = 3
} obj_const_type;

typedef struct obj_const {
	const char      *name;    /**< constant's name. */
	const char      *str;
	double          num;
	obj_const_type  type;
} obj_const;

typedef enum obj_field_type {
	TYPE_UNKOWN    = 0,
	TYPE_UINT8     = 1,
	TYPE_UINT16    = 2,
	TYPE_UINT32    = 3,
	TYPE_UINT64    = 4,
	TYPE_INT8      = 5,
	TYPE_INT16     = 6,
	TYPE_INT32     = 7,
	TYPE_INT64     = 8,
	TYPE_DOUBLE    = 9,
	TYPE_FLOAT     = 10,
	TYPE_STRING    = 11
} obj_field_type;

typedef struct obj_field {
	const char      *name;  /**< field's name. */
	uint32_t        offset; /**< offset to field's data. */
	obj_field_type  type;   /**< field's data type. */
	uint32_t        flags;  /**< is_writable:1bit */
} obj_field;

typedef struct reg_sub_module {
	obj_type        *type;
	int             is_package;
	const luaL_reg  *pub_funcs;
	const luaL_reg  *methods;
	const luaL_reg  *metas;
	const obj_base  *bases;
	const obj_field *fields;
	const obj_const *constants;
} reg_sub_module;

#define OBJ_UDATA_FLAG_OWN (1<<0)
#define OBJ_UDATA_FLAG_LOOKUP (1<<1)
typedef struct obj_udata {
	void     *obj;
	uint32_t flags;  /**< lua_own:1bit */
} obj_udata;

/* use static pointer as key to weak userdata table. */
static char *obj_udata_weak_ref_key = "obj_udata_weak_ref_key";


#define obj_type_id_ZMQ_Ctx 0
#define obj_type_ZMQ_Ctx_check(L, _index) \
  obj_udata_luacheck(L, _index, &(obj_type_ZMQ_Ctx))
#define obj_type_ZMQ_Ctx_delete(L, _index, flags) \
  obj_udata_luadelete(L, _index, &(obj_type_ZMQ_Ctx), flags)
#define obj_type_ZMQ_Ctx_push(L, obj, flags) \
  obj_udata_luapush_weak(L, (void *)obj, &(obj_type_ZMQ_Ctx), flags)

#define obj_type_id_ZMQ_Socket 1
#define obj_type_ZMQ_Socket_check(L, _index) \
  obj_udata_luacheck(L, _index, &(obj_type_ZMQ_Socket))
#define obj_type_ZMQ_Socket_delete(L, _index, flags) \
  obj_udata_luadelete(L, _index, &(obj_type_ZMQ_Socket), flags)
#define obj_type_ZMQ_Socket_push(L, obj, flags) \
  obj_udata_luapush_weak(L, (void *)obj, &(obj_type_ZMQ_Socket), flags)



typedef int ZMQ_Error;

static void error_code__ZMQ_Error__push(lua_State *L, ZMQ_Error err);


static obj_type obj_type_ZMQ_Ctx = { NULL, 0, OBJ_TYPE_FLAG_WEAK_REF, "ZMQ_Ctx" };
static obj_type obj_type_ZMQ_Socket = { NULL, 1, OBJ_TYPE_FLAG_WEAK_REF, "ZMQ_Socket" };


#ifndef REG_PACKAGE_IS_CONSTRUCTOR
#define REG_PACKAGE_IS_CONSTRUCTOR 1
#endif

#ifndef REG_OBJECTS_AS_GLOBALS
#define REG_OBJECTS_AS_GLOBALS 0
#endif

#ifndef OBJ_DATA_HIDDEN_METATABLE
#define OBJ_DATA_HIDDEN_METATABLE 1
#endif

static FUNC_UNUSED obj_udata *obj_udata_toobj(lua_State *L, int _index) {
	obj_udata *ud;
	size_t len;

	/* make sure it's a userdata value. */
	ud = (obj_udata *)lua_touserdata(L, _index);
	if(ud == NULL) {
		luaL_typerror(L, _index, "userdata"); /* is not a userdata value. */
	}
	/* verify userdata size. */
	len = lua_objlen(L, _index);
	if(len != sizeof(obj_udata)) {
		/* This shouldn't be possible */
		luaL_error(L, "invalid userdata size: size=%d, expected=%d", len, sizeof(obj_udata));
	}
	return ud;
}

static FUNC_UNUSED int obj_udata_is_compatible(lua_State *L, obj_udata *ud, void **obj, base_caster_t *caster, obj_type *type) {
	obj_base *base;
	obj_type *ud_type;
	lua_pushlightuserdata(L, type);
	lua_rawget(L, LUA_REGISTRYINDEX); /* type's metatable. */
	if(lua_rawequal(L, -1, -2)) {
		*obj = ud->obj;
		/* same type no casting needed. */
		return 1;
	} else {
		/* Different types see if we can cast to the required type. */
		lua_rawgeti(L, -2, type->id);
		base = lua_touserdata(L, -1);
		lua_pop(L, 1); /* pop obj_base or nil */
		if(base != NULL) {
			*caster = base->bcaster;
			/* get the obj_type for this userdata. */
			lua_pushliteral(L, ".type");
			lua_rawget(L, -3); /* type's metatable. */
			ud_type = lua_touserdata(L, -1);
			lua_pop(L, 1); /* pop obj_type or nil */
			if(base == NULL) {
				luaL_error(L, "bad userdata, missing type info.");
				return 0;
			}
			/* check if userdata is a simple object. */
			if(ud_type->flags & OBJ_TYPE_SIMPLE) {
				*obj = ud;
			} else {
				*obj = ud->obj;
			}
			return 1;
		}
	}
	return 0;
}

static FUNC_UNUSED obj_udata *obj_udata_luacheck_internal(lua_State *L, int _index, void **obj, obj_type *type) {
	obj_udata *ud;
	base_caster_t caster = NULL;
	/* make sure it's a userdata value. */
	ud = (obj_udata *)lua_touserdata(L, _index);
	if(ud != NULL) {
		/* check object type by comparing metatables. */
		if(lua_getmetatable(L, _index)) {
			if(obj_udata_is_compatible(L, ud, obj, &(caster), type)) {
				lua_pop(L, 2); /* pop both metatables. */
				/* apply caster function if needed. */
				if(caster != NULL && *obj != NULL) {
					caster(obj);
				}
				/* check object pointer. */
				if(*obj == NULL) {
					luaL_error(L, "null %s", type->name); /* object was garbage collected? */
				}
				return ud;
			}
		}
	}
	luaL_typerror(L, _index, type->name); /* is not a userdata value. */
	return NULL;
}

static FUNC_UNUSED void *obj_udata_luacheck(lua_State *L, int _index, obj_type *type) {
	void *obj = NULL;
	obj_udata_luacheck_internal(L, _index, &(obj), type);
	return obj;
}

static FUNC_UNUSED void *obj_udata_luadelete(lua_State *L, int _index, obj_type *type, int *flags) {
	void *obj;
#if OBJ_DATA_HIDDEN_METATABLE
	obj_udata *ud = obj_udata_toobj(L, _index);
	(void)type;
	obj = ud->obj;
#else
	obj_udata *ud = obj_udata_luacheck_internal(L, _index, &(obj), type);
#endif
	*flags = ud->flags;
	/* null userdata. */
	ud->obj = NULL;
	ud->flags = 0;
	/* clear the metatable to invalidate userdata. */
	lua_pushnil(L);
	lua_setmetatable(L, _index);
	return obj;
}

static FUNC_UNUSED void obj_udata_luapush(lua_State *L, void *obj, obj_type *type, int flags) {
	/* convert NULL's into Lua nil's. */
	if(obj == NULL) {
		lua_pushnil(L);
		return;
	}
	/* check for type caster. */
	if(type->dcaster) {
		(type->dcaster)(&obj, &type);
	}
	/* create new userdata. */
	obj_udata *ud = (obj_udata *)lua_newuserdata(L, sizeof(obj_udata));
	ud->obj = obj;
	ud->flags = flags;
	/* get obj_type metatable. */
	lua_pushlightuserdata(L, type);
	lua_rawget(L, LUA_REGISTRYINDEX); /* type's metatable. */
	lua_setmetatable(L, -2);
}

static FUNC_UNUSED void obj_udata_luapush_weak(lua_State *L, void *obj, obj_type *type, int flags) {
	obj_udata *ud;

	/* convert NULL's into Lua nil's. */
	if(obj == NULL) {
		lua_pushnil(L);
		return;
	}
	/* check for type caster. */
	if(type->dcaster) {
		(type->dcaster)(&obj, &type);
	}
	/* get objects weak table. */
	lua_pushlightuserdata(L, obj_udata_weak_ref_key);
	lua_rawget(L, LUA_REGISTRYINDEX); /* weak ref table. */
	/* lookup userdata instance from pointer. */
	lua_pushlightuserdata(L, obj);
	lua_rawget(L, -2);
	if(!lua_isnil(L, -1)) {
		lua_remove(L, -2);     /* remove objects table. */
		return;
	}
	lua_pop(L, 1);  /* pop nil. */

	/* create new userdata. */
	ud = (obj_udata *)lua_newuserdata(L, sizeof(obj_udata));

	/* init. obj_udata. */
	ud->obj = obj;
	ud->flags = flags;
	/* get obj_type metatable. */
	lua_pushlightuserdata(L, type);
	lua_rawget(L, LUA_REGISTRYINDEX); /* type's metatable. */
	lua_setmetatable(L, -2);

	/* add weak reference to object. */
	lua_pushlightuserdata(L, obj); /* push object pointer as the 'key' */
	lua_pushvalue(L, -2);          /* push object's udata */
	lua_rawset(L, -4);             /* add weak reference to object. */
	lua_remove(L, -2);     /* remove objects table. */
}

/* default object equal method. */
static FUNC_UNUSED int obj_udata_default_equal(lua_State *L) {
	obj_udata *ud1 = obj_udata_toobj(L, 1);
	obj_udata *ud2 = obj_udata_toobj(L, 2);

	lua_pushboolean(L, (ud1->obj == ud2->obj));
	return 1;
}

/* default object tostring method. */
static FUNC_UNUSED int obj_udata_default_tostring(lua_State *L) {
	obj_udata *ud = obj_udata_toobj(L, 1);

	/* get object's metatable. */
	lua_getmetatable(L, 1);
	lua_remove(L, 1); /* remove userdata. */
	/* get the object's name from the metatable */
	lua_getfield(L, 1, ".name");
	lua_remove(L, 1); /* remove metatable */
	/* push object's pointer */
	lua_pushfstring(L, ": %p, flags=%d", ud->obj, ud->flags);
	lua_concat(L, 2);

	return 1;
}

/*
 * Simple userdata objects.
 */
static FUNC_UNUSED void *obj_simple_udata_toobj(lua_State *L, int _index) {
	void *ud;

	/* make sure it's a userdata value. */
	ud = lua_touserdata(L, _index);
	if(ud == NULL) {
		luaL_typerror(L, _index, "userdata"); /* is not a userdata value. */
	}
	return ud;
}

static FUNC_UNUSED void * obj_simple_udata_luacheck(lua_State *L, int _index, obj_type *type) {
	void *ud;
	/* make sure it's a userdata value. */
	ud = lua_touserdata(L, _index);
	if(ud != NULL) {
		/* check object type by comparing metatables. */
		if(lua_getmetatable(L, _index)) {
			lua_pushlightuserdata(L, type);
			lua_rawget(L, LUA_REGISTRYINDEX); /* type's metatable. */
			if(lua_rawequal(L, -1, -2)) {
				lua_pop(L, 2); /* pop both metatables. */
				return ud;
			}
		}
	}
	luaL_typerror(L, _index, type->name); /* is not a userdata value. */
	return NULL;
}

static FUNC_UNUSED void * obj_simple_udata_luadelete(lua_State *L, int _index, obj_type *type, int *flags) {
	void *obj;
#if OBJ_DATA_HIDDEN_METATABLE
	obj = obj_simple_udata_toobj(L, _index);
	(void)type;
#else
	obj = obj_simple_udata_luacheck(L, _index, type);
#endif
	*flags = OBJ_UDATA_FLAG_OWN;
	return obj;
}

static FUNC_UNUSED void obj_simple_udata_luapush(lua_State *L, void *obj, int size, obj_type *type)
{
	/* create new userdata. */
	void *ud = lua_newuserdata(L, size);
	memcpy(ud, obj, size);
	/* get obj_type metatable. */
	lua_pushlightuserdata(L, type);
	lua_rawget(L, LUA_REGISTRYINDEX); /* type's metatable. */
	lua_setmetatable(L, -2);
}

/* default simple object equal method. */
static FUNC_UNUSED int obj_simple_udata_default_equal(lua_State *L) {
	void *ud1 = obj_simple_udata_toobj(L, 1);
	size_t len1 = lua_objlen(L, 1);
	void *ud2 = obj_simple_udata_toobj(L, 2);
	size_t len2 = lua_objlen(L, 2);

	if(len1 == len2) {
		lua_pushboolean(L, (memcmp(ud1, ud2, len1) == 0));
	} else {
		lua_pushboolean(L, 0);
	}
	return 1;
}

/* default simple object tostring method. */
static FUNC_UNUSED int obj_simple_udata_default_tostring(lua_State *L) {
	void *ud = obj_simple_udata_toobj(L, 1);

	/* get object's metatable. */
	lua_getmetatable(L, 1);
	lua_remove(L, 1); /* remove userdata. */
	/* get the object's name from the metatable */
	lua_getfield(L, 1, ".name");
	lua_remove(L, 1); /* remove metatable */
	/* push object's pointer */
	lua_pushfstring(L, ": %p", ud);
	lua_concat(L, 2);

	return 1;
}

static int obj_constructor_call_wrapper(lua_State *L) {
	/* replace '__call' table with constructor function. */
	lua_pushvalue(L, lua_upvalueindex(1));
	lua_replace(L, 1);

	/* call constructor function with all parameters after the '__call' table. */
	lua_call(L, lua_gettop(L) - 1, LUA_MULTRET);
	/* return all results from constructor. */
	return lua_gettop(L);
}

static void obj_type_register_constants(lua_State *L, const obj_const *constants, int tab_idx) {
	/* register constants. */
	while(constants->name != NULL) {
		lua_pushstring(L, constants->name);
		switch(constants->type) {
		case CONST_BOOLEAN:
			lua_pushboolean(L, constants->num != 0.0);
			break;
		case CONST_NUMBER:
			lua_pushnumber(L, constants->num);
			break;
		case CONST_STRING:
			lua_pushstring(L, constants->str);
			break;
		default:
			lua_pushnil(L);
			break;
		}
		lua_rawset(L, tab_idx - 2);
		constants++;
	}
}

static void obj_type_register_package(lua_State *L, const reg_sub_module *type_reg) {
	obj_type *type = type_reg->type;
	const luaL_reg *reg_list = type_reg->pub_funcs;

	/* create public functions table. */
	if(reg_list != NULL && reg_list[0].name != NULL) {
		/* register functions */
		luaL_register(L, NULL, reg_list);
	}

	obj_type_register_constants(L, type_reg->constants, -1);

	lua_pop(L, 1);  /* drop package table */
}

static void obj_type_register(lua_State *L, const reg_sub_module *type_reg) {
	const luaL_reg *reg_list;
	obj_type *type = type_reg->type;
	const obj_base *base = type_reg->bases;

	if(type_reg->is_package == 1) {
		return obj_type_register_package(L, type_reg);
	}

	/* create public functions table. */
	reg_list = type_reg->pub_funcs;
	if(reg_list != NULL && reg_list[0].name != NULL) {
		/* register "constructors" as to object's public API */
		luaL_register(L, NULL, reg_list); /* fill public API table. */

		/* make public API table callable as the default constructor. */
		lua_newtable(L); /* create metatable */
		lua_pushliteral(L, "__call");
		lua_pushcfunction(L, reg_list[0].func); /* push first constructor function. */
		lua_pushcclosure(L, obj_constructor_call_wrapper, 1); /* make __call wrapper. */
		lua_rawset(L, -3);         /* metatable.__call = <default constructor> */
		lua_setmetatable(L, -2);

		lua_pop(L, 1); /* pop public API table, don't need it any more. */
		/* create methods table. */
		lua_newtable(L);
	} else {
		/* register all methods as public functions. */
	}

	luaL_register(L, NULL, type_reg->methods); /* fill methods table. */

	luaL_newmetatable(L, type->name); /* create metatable */
	lua_pushliteral(L, ".name");
	lua_pushstring(L, type->name);
	lua_rawset(L, -3);    /* metatable['.name'] = "<object_name>" */
	lua_pushliteral(L, ".type");
	lua_pushlightuserdata(L, type);
	lua_rawset(L, -3);    /* metatable['.type'] = lightuserdata -> obj_type */
	lua_pushlightuserdata(L, type);
	lua_pushvalue(L, -2); /* dup metatable. */
	lua_rawset(L, LUA_REGISTRYINDEX);    /* REGISTRY[type] = metatable */

	luaL_register(L, NULL, type_reg->metas); /* fill metatable */

	/* add obj_bases to metatable. */
	while(base->id >= 0) {
		lua_pushlightuserdata(L, (void *)base);
		lua_rawseti(L, -2, base->id);
		base++;
	}

	obj_type_register_constants(L, type_reg->constants, -2);

	lua_pushliteral(L, "__index");
	lua_pushvalue(L, -3);               /* dup methods table */
	lua_rawset(L, -3);                  /* metatable.__index = methods */
#if OBJ_DATA_HIDDEN_METATABLE
	lua_pushliteral(L, "__metatable");
	lua_pushvalue(L, -3);               /* dup methods table */
	lua_rawset(L, -3);                  /* hide metatable:
	                                       metatable.__metatable = methods */
#endif
	lua_pop(L, 2);                      /* drop metatable & methods */
}

static FUNC_UNUSED int lua_checktype_ref(lua_State *L, int _index, int _type) {
	luaL_checktype(L,_index,_type);
	lua_pushvalue(L,_index);
	return luaL_ref(L, LUA_REGISTRYINDEX);
}

#if LUAJIT_FFI
static int nobj_try_loading_ffi(lua_State *L, const char *ffi_init_code) {
	int err;

	err = luaL_loadstring(L, ffi_init_code);

	lua_pushvalue(L, -2); /* dup C module's table. */
	err = lua_pcall(L, 1, 0, 0);
	if(err) {
		lua_pop(L, 1); /* pop error message. */
	}
	return err;
}
#endif


static const char *zmq_ffi_lua_code = "\
local zmq = ...\n\
\n\
-- try loading luajit's ffi\n\
local stat, ffi=pcall(require,\"ffi\")\n\
if not stat then\n\
	print(\"No FFI module: ZMQ using standard Lua api interface.\")\n\
	return\n\
end\n\
-- check if ffi is disabled.\n\
if disable_ffi then\n\
	print(\"FFI disabled: ZMQ using standard Lua api interface.\")\n\
	return\n\
end\n\
\n\
local setmetatable = setmetatable\n\
local getmetatable = getmetatable\n\
local print = print\n\
local pairs = pairs\n\
local error = error\n\
local type = type\n\
local assert = assert\n\
local tostring = tostring\n\
local tonumber = tonumber\n\
local newproxy = newproxy\n\
\n\
ffi.cdef[[\n\
void zmq_version (int *major, int *minor, int *patch);\n\
int zmq_errno ();\n\
const char *zmq_strerror (int errnum);\n\
\n\
typedef struct zmq_msg_t\n\
{\n\
    void *content;\n\
    unsigned char flags;\n\
    unsigned char vsm_size;\n\
    unsigned char vsm_data [30];\n\
} zmq_msg_t;\n\
\n\
typedef void (zmq_free_fn) (void *data, void *hint);\n\
\n\
int zmq_msg_init (zmq_msg_t *msg);\n\
int zmq_msg_init_size (zmq_msg_t *msg, size_t size);\n\
int zmq_msg_init_data (zmq_msg_t *msg, void *data, size_t size, zmq_free_fn *ffn, void *hint);\n\
int zmq_msg_close (zmq_msg_t *msg);\n\
int zmq_msg_move (zmq_msg_t *dest, zmq_msg_t *src);\n\
int zmq_msg_copy (zmq_msg_t *dest, zmq_msg_t *src);\n\
void *zmq_msg_data (zmq_msg_t *msg);\n\
size_t zmq_msg_size (zmq_msg_t *msg);\n\
\n\
void *zmq_init (int io_threads);\n\
int zmq_term (void *context);\n\
\n\
void *zmq_socket (void *context, int type);\n\
int zmq_close (void *s);\n\
int zmq_setsockopt (void *s, int option, const void *optval, size_t optvallen);\n\
int zmq_getsockopt (void *s, int option, void *optval, size_t *optvallen);\n\
int zmq_bind (void *s, const char *addr);\n\
int zmq_connect (void *s, const char *addr);\n\
int zmq_send (void *s, zmq_msg_t *msg, int flags);\n\
int zmq_recv (void *s, zmq_msg_t *msg, int flags);\n\
\n\
int zmq_device (int device, void * insocket, void* outsocket);\n\
\n\
]]\n\
\n\
local C = ffi.load\"zmq\"\n\
\n\
-- simulate: module(...)\n\
zmq._M = zmq\n\
setfenv(1, zmq)\n\
\n\
function version()\n\
	local major = ffi.new('int[1]',0)\n\
	local minor = ffi.new('int[1]',0)\n\
	local patch = ffi.new('int[1]',0)\n\
	C.zmq_version(major, minor, patch)\n\
	return {major[0], minor[0], patch[0]}\n\
end\n\
\n\
local function zmq_error()\n\
	local errno = C.zmq_errno()\n\
	local err = ffi.string(C.zmq_strerror(errno))\n\
	if err == \"Resource temporarily unavailable\" then err = \"timeout\" end\n\
	if err == \"Context was terminated\" then err = \"closed\" end\n\
	return nil, err\n\
end\n\
\n\
--\n\
-- ZMQ socket\n\
--\n\
local sock_mt = {}\n\
sock_mt.__index = sock_mt\n\
\n\
function sock_mt:close()\n\
	-- get the true self\n\
	self=getmetatable(self)\n\
	local sock = self.sock\n\
	-- make sure socket is still valid.\n\
	if not sock then return end\n\
	-- close zmq socket.\n\
	local ret = C.zmq_close(sock)\n\
	-- mark this socket as closed.\n\
	self.sock = nil\n\
	if ret ~= 0 then\n\
		return zmq_error()\n\
	end\n\
	return true\n\
end\n\
\n\
local option_types = {\n\
[zmq.HWM] = 'uint64_t[1]',\n\
[zmq.SWAP] = 'int64_t[1]',\n\
[zmq.AFFINITY] = 'uint64_t[1]',\n\
[zmq.IDENTITY] = 'string',\n\
[zmq.SUBSCRIBE] = 'string',\n\
[zmq.UNSUBSCRIBE] = 'string',\n\
[zmq.RATE] = 'int64_t[1]',\n\
[zmq.RECOVERY_IVL] = 'int64_t[1]',\n\
[zmq.MCAST_LOOP] = 'int64_t[1]',\n\
[zmq.SNDBUF] = 'uint64_t[1]',\n\
[zmq.RCVBUF] = 'uint64_t[1]',\n\
[zmq.RCVMORE] = 'int64_t[1]',\n\
[zmq.FD] = 'int[1]',\n\
[zmq.EVENTS] = 'uint32_t[1]',\n\
[zmq.TYPE] = 'int[1]',\n\
[zmq.LINGER] = 'int[1]',\n\
[zmq.RECONNECT_IVL] = 'int[1]',\n\
[zmq.BACKLOG] = 'int[1]',\n\
}\n\
local option_len = {}\n\
local option_tmps = {}\n\
for k,v in pairs(option_types) do\n\
	if v ~= 'string' then\n\
		option_len[k] = ffi.sizeof(v)\n\
		option_tmps[k] = ffi.new(v, 0)\n\
	end\n\
end\n\
function sock_mt:setopt(opt, opt_val)\n\
	local ctype = option_types[opt]\n\
	local val_len = 0\n\
	if ctype == 'string' then\n\
		--val = ffi.cast('void *', tostring(val))\n\
		val = tostring(opt_val)\n\
		val_len = #val\n\
	else\n\
		val = option_tmps[opt]\n\
		val[0] = opt_val\n\
		val_len = option_len[opt]\n\
	end\n\
	local ret = C.zmq_setsockopt(self.sock, opt, val, val_len)\n\
	if ret ~= 0 then\n\
		return zmq_error()\n\
	end\n\
	return true\n\
end\n\
\n\
local tmp_val_len = ffi.new('size_t[1]', 4)\n\
function sock_mt:getopt(opt)\n\
	local ctype = option_types[opt]\n\
	local val\n\
	local val_len = tmp_val_len\n\
	if ctype == 'string' then\n\
		val_len[0] = 255\n\
		val = ffi.new('uint8_t[?]', val_len[0])\n\
		ffi.fill(val, val_len[0])\n\
	else\n\
		val = option_tmps[opt]\n\
		val[0] = 0\n\
		val_len[0] = option_len[opt]\n\
	end\n\
	local ret = C.zmq_getsockopt(self.sock, opt, val, val_len)\n\
	if ret ~= 0 then\n\
		return zmq_error()\n\
	end\n\
	if ctype == 'string' then\n\
		val_len = val_len[0]\n\
		return ffi.string(val, val_len)\n\
	else\n\
		val = val[0]\n\
	end\n\
	return tonumber(val)\n\
end\n\
\n\
local tmp32 = ffi.new('uint32_t[1]', 0)\n\
local tmp32_len = ffi.new('size_t[1]', 4)\n\
function sock_mt:events()\n\
	local val = tmp32\n\
	local val_len = tmp32_len\n\
	val[0] = 0\n\
	val_len[0] = 4\n\
	local ret = C.zmq_getsockopt(self.sock, 15, val, val_len)\n\
	if ret ~= 0 then\n\
		return zmq_error()\n\
	end\n\
	return val[0]\n\
end\n\
\n\
function sock_mt:bind(addr)\n\
	local ret = C.zmq_bind(self.sock, addr)\n\
	if ret ~= 0 then\n\
		return zmq_error()\n\
	end\n\
	return true\n\
end\n\
\n\
function sock_mt:connect(addr)\n\
	local ret = C.zmq_connect(self.sock, addr)\n\
	if ret ~= 0 then\n\
		return zmq_error()\n\
	end\n\
	return true\n\
end\n\
\n\
local tmp_msg = ffi.new('zmq_msg_t')\n\
function sock_mt:send(data, flags)\n\
	local msg = tmp_msg\n\
	local msg_len = #data\n\
	-- initialize message\n\
	if C.zmq_msg_init_size(msg, msg_len) < 0 then\n\
		return zmq_error()\n\
	end\n\
	-- copy data into message.\n\
	ffi.copy(C.zmq_msg_data(msg), data, msg_len)\n\
\n\
	-- send message\n\
	local ret = C.zmq_send(self.sock, msg, flags or 0)\n\
	-- close message before processing return code\n\
	C.zmq_msg_close(msg)\n\
	-- now process send return code\n\
	if ret ~= 0 then\n\
		return zmq_error()\n\
	end\n\
	return true\n\
end\n\
\n\
function sock_mt:recv(flags)\n\
	local msg = tmp_msg\n\
	-- initialize blank message.\n\
	if C.zmq_msg_init(msg) < 0 then\n\
		return zmq_error()\n\
	end\n\
\n\
	-- receive message\n\
	local ret = C.zmq_recv(self.sock, msg, flags or 0)\n\
	if ret ~= 0 then\n\
		local data, err = zmq_error()\n\
		C.zmq_msg_close(msg)\n\
		return data, err\n\
	end\n\
	local data = ffi.string(C.zmq_msg_data(msg), C.zmq_msg_size(msg))\n\
	-- close message\n\
	C.zmq_msg_close(msg)\n\
	return data\n\
end\n\
\n\
--\n\
-- ZMQ context\n\
--\n\
local ctx_mt = {}\n\
ctx_mt.__index = ctx_mt\n\
\n\
function ctx_mt:term()\n\
	if C.zmq_term(self.ctx) ~= 0 then\n\
		return zmq_error()\n\
	end\n\
	return true\n\
end\n\
\n\
function ctx_mt:socket(sock_type)\n\
	local sock = C.zmq_socket(self.ctx, sock_type)\n\
	if not sock then\n\
		return zmq_error()\n\
	end\n\
	-- use a wrapper newproxy for __gc support\n\
	local self=newproxy(true)\n\
	local meta=getmetatable(self)\n\
	meta.__index = meta\n\
	meta.sock = sock\n\
	meta.__gc = function() self:close() end\n\
	setmetatable(meta, sock_mt)\n\
	return self\n\
end\n\
\n\
function init(io_threads)\n\
	print(\"ZMQ using FFI interface.\")\n\
	local ctx = C.zmq_init(io_threads)\n\
	if not ctx then\n\
		return zmq_error()\n\
	end\n\
	return setmetatable({ ctx = ctx }, ctx_mt)\n\
end\n\
\n\
\n\
";

typedef void * ZMQ_Ctx;

/* detect zmq version >= 2.1.0 */
#define VERSION_2_1 0
#if defined(ZMQ_VERSION)
#if (ZMQ_VERSION >= ZMQ_MAKE_VERSION(2,1,0))
#undef VERSION_2_1
#define VERSION_2_1 1
#endif
#endif

typedef void * ZMQ_Socket;

#if VERSION_2_1
#ifdef _WIN32
#include <winsock2.h>
typedef SOCKET socket_t;
#else
typedef int socket_t;
#endif
#endif

/* socket option types. */
#define OPT_TYPE_NONE		0
#define OPT_TYPE_INT		1
#define OPT_TYPE_UINT32	2
#define OPT_TYPE_UINT64	3
#define OPT_TYPE_INT64	4
#define OPT_TYPE_STR		5
#define OPT_TYPE_FD			6

static const int opt_types[] = {
	OPT_TYPE_NONE,		/* unused */
	OPT_TYPE_UINT64,	/* ZMQ_HWM */
	OPT_TYPE_INT64,		/* ZMQ_SWAP */
	OPT_TYPE_UINT64,	/* ZMQ_AFFINITY */
	OPT_TYPE_STR,			/* ZMQ_IDENTITY */
	OPT_TYPE_STR,			/* ZMQ_SUBSCRIBE */
	OPT_TYPE_STR,			/* ZMQ_UNSUBSCRIBE */
	OPT_TYPE_INT64,		/* ZMQ_RATE */
	OPT_TYPE_INT64,		/* ZMQ_RECOVERY_IVL */
	OPT_TYPE_INT64,		/* ZMQ_MCAST_LOOP */
	OPT_TYPE_UINT64,	/* ZMQ_SNDBUF */
	OPT_TYPE_UINT64,	/* ZMQ_RCVBUF */
	OPT_TYPE_INT64,		/* ZMQ_RCVMORE */

#if VERSION_2_1
	OPT_TYPE_FD,			/* ZMQ_FD */
	OPT_TYPE_UINT32,	/* ZMQ_EVENTS */
	OPT_TYPE_INT,			/* ZMQ_TYPE */
	OPT_TYPE_INT,			/* ZMQ_LINGER */
	OPT_TYPE_INT,			/* ZMQ_RECONNECT_IVL */
	OPT_TYPE_INT,			/* ZMQ_BACKLOG */
#endif
};
#define MAX_OPTS ZMQ_BACKLOG




/* method: version */
static int zmq__version__func(lua_State *L) {
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

  return 1;
}

/* method: init */
static int zmq__init__func(lua_State *L) {
  int is_error = 0;
  int io_threads_idx1 = luaL_checkinteger(L,1);
  ZMQ_Ctx ctx_idx1;
  ZMQ_Error err_idx2 = 0;
	ctx_idx1 = zmq_init(io_threads_idx1);
	if(ctx_idx1 == NULL) err_idx2 = -1;

  is_error = (0 != err_idx2);
  if(is_error) {
    lua_pushnil(L);
  } else {
    obj_type_ZMQ_Ctx_push(L, ctx_idx1, OBJ_UDATA_FLAG_OWN);
  }
  error_code__ZMQ_Error__push(L, err_idx2);
  return 2;
}

/* method: device */
static int zmq__device__func(lua_State *L) {
  int is_error = 0;
  ZMQ_Error ret_idx1 = 0;
  int device_idx1 = luaL_checkinteger(L,1);
  ZMQ_Socket insock_idx2 = obj_type_ZMQ_Socket_check(L,2);
  ZMQ_Socket outsock_idx3 = obj_type_ZMQ_Socket_check(L,3);
  ret_idx1 = zmq_device(device_idx1, insock_idx2, outsock_idx3);
  is_error = (0 != ret_idx1);
  if(is_error) {
    lua_pushnil(L);
      error_code__ZMQ_Error__push(L, ret_idx1);
  } else {
    lua_pushboolean(L, 1);
    lua_pushnil(L);
  }
  return 2;
}

static void error_code__ZMQ_Error__push(lua_State *L, ZMQ_Error err) {
  const char *err_str = NULL;
	if(err != 0) {
		err = zmq_errno();
		switch(err) {
		case EAGAIN:
			err_str = "timeout";
			break;
		case ETERM:
			err_str = "closed";
			break;
		default:
			err_str = zmq_strerror(err);
			break;
		}
	}

	if(err_str) {
		lua_pushstring(L, err_str);
	} else {
		lua_pushnil(L);
	}
}

/* method: term */
static int ZMQ_Ctx__term__meth(lua_State *L) {
  int is_error = 0;
  int flags = 0;
  ZMQ_Ctx * this_idx1 = obj_type_ZMQ_Ctx_delete(L,1,&(flags));
  if(!(flags & OBJ_UDATA_FLAG_OWN)) { return 0; }
  ZMQ_Error ret_idx1 = 0;
  ret_idx1 = zmq_term(this_idx1);
  is_error = (0 != ret_idx1);
  if(is_error) {
    lua_pushnil(L);
      error_code__ZMQ_Error__push(L, ret_idx1);
  } else {
    lua_pushboolean(L, 1);
    lua_pushnil(L);
  }
  return 2;
}

/* method: socket */
static int ZMQ_Ctx__socket__meth(lua_State *L) {
  int is_error = 0;
  ZMQ_Ctx * this_idx1 = obj_type_ZMQ_Ctx_check(L,1);
  int type_idx2 = luaL_checkinteger(L,2);
  ZMQ_Socket sock_idx1;
  ZMQ_Error err_idx2 = 0;
	sock_idx1 = zmq_socket(this_idx1, type_idx2);
	if(sock_idx1 == NULL) err_idx2 = -1;

  is_error = (0 != err_idx2);
  if(is_error) {
    lua_pushnil(L);
  } else {
    obj_type_ZMQ_Socket_push(L, sock_idx1, OBJ_UDATA_FLAG_OWN);
  }
  error_code__ZMQ_Error__push(L, err_idx2);
  return 2;
}

/* method: close */
static int ZMQ_Socket__close__meth(lua_State *L) {
  int is_error = 0;
  int flags = 0;
  ZMQ_Socket * this_idx1 = obj_type_ZMQ_Socket_delete(L,1,&(flags));
  if(!(flags & OBJ_UDATA_FLAG_OWN)) { return 0; }
  ZMQ_Error ret_idx1 = 0;
  ret_idx1 = zmq_close(this_idx1);
  is_error = (0 != ret_idx1);
  if(is_error) {
    lua_pushnil(L);
      error_code__ZMQ_Error__push(L, ret_idx1);
  } else {
    lua_pushboolean(L, 1);
    lua_pushnil(L);
  }
  return 2;
}

/* method: bind */
static int ZMQ_Socket__bind__meth(lua_State *L) {
  int is_error = 0;
  ZMQ_Socket * this_idx1 = obj_type_ZMQ_Socket_check(L,1);
  ZMQ_Error ret_idx1 = 0;
  size_t addr_idx2_len;
  const char * addr_idx2 = luaL_checklstring(L,2,&(addr_idx2_len));
  ret_idx1 = zmq_bind(this_idx1, addr_idx2);
  is_error = (0 != ret_idx1);
  if(is_error) {
    lua_pushnil(L);
      error_code__ZMQ_Error__push(L, ret_idx1);
  } else {
    lua_pushboolean(L, 1);
    lua_pushnil(L);
  }
  return 2;
}

/* method: connect */
static int ZMQ_Socket__connect__meth(lua_State *L) {
  int is_error = 0;
  ZMQ_Socket * this_idx1 = obj_type_ZMQ_Socket_check(L,1);
  ZMQ_Error ret_idx1 = 0;
  size_t addr_idx2_len;
  const char * addr_idx2 = luaL_checklstring(L,2,&(addr_idx2_len));
  ret_idx1 = zmq_connect(this_idx1, addr_idx2);
  is_error = (0 != ret_idx1);
  if(is_error) {
    lua_pushnil(L);
      error_code__ZMQ_Error__push(L, ret_idx1);
  } else {
    lua_pushboolean(L, 1);
    lua_pushnil(L);
  }
  return 2;
}

/* method: setopt */
static int ZMQ_Socket__setopt__meth(lua_State *L) {
  int is_error = 0;
  ZMQ_Socket * this_idx1 = obj_type_ZMQ_Socket_check(L,1);
  uint32_t opt_idx2 = luaL_checkinteger(L,2);
  ZMQ_Error err_idx1 = 0;
	size_t val_len;
	const void *val;

	socket_t fd_val;
	int int_val;
	uint32_t uint32_val;
	uint64_t uint64_val;
	int64_t int64_val;

	if(opt_idx2 > MAX_OPTS) {
		return luaL_argerror(L, 2, "Invalid socket option.");
	}

	switch(opt_types[opt_idx2]) {
	case OPT_TYPE_FD:
		fd_val = luaL_checklong(L, 3);
		val = &fd_val;
		val_len = sizeof(fd_val);
		break;
	case OPT_TYPE_INT:
		int_val = luaL_checklong(L, 3);
		val = &int_val;
		val_len = sizeof(int_val);
		break;
	case OPT_TYPE_UINT32:
		uint32_val = luaL_checklong(L, 3);
		val = &uint32_val;
		val_len = sizeof(uint32_val);
		break;
	case OPT_TYPE_UINT64:
		uint64_val = luaL_checklong(L, 3);
		val = &uint64_val;
		val_len = sizeof(uint64_val);
		break;
	case OPT_TYPE_INT64:
		int64_val = luaL_checklong(L, 3);
		val = &int64_val;
		val_len = sizeof(int64_val);
		break;
	case OPT_TYPE_STR:
		val = luaL_checklstring(L, 3, &(val_len));
		break;
	default:
		printf("Invalid socket option type, this shouldn't happen.\n");
		abort();
		break;
	}
	err_idx1 = zmq_setsockopt(this_idx1, opt_idx2, val, val_len);

  is_error = (0 != err_idx1);
  if(is_error) {
    lua_pushnil(L);
      error_code__ZMQ_Error__push(L, err_idx1);
  } else {
    lua_pushboolean(L, 1);
    lua_pushnil(L);
  }
  return 2;
}

/* method: getopt */
static int ZMQ_Socket__getopt__meth(lua_State *L) {
  int is_error = 0;
  ZMQ_Socket * this_idx1 = obj_type_ZMQ_Socket_check(L,1);
  uint32_t opt_idx2 = luaL_checkinteger(L,2);
  ZMQ_Error err_idx2 = 0;
	size_t val_len;

	socket_t fd_val;
	int int_val;
	uint32_t uint32_val;
	uint64_t uint64_val;
	int64_t int64_val;
#define STR_MAX 255
	char str_val[STR_MAX];

	if(opt_idx2 > MAX_OPTS) {
		lua_pushnil(L);
		lua_pushliteral(L, "Invalid socket option.");
		return 2;
	}

	switch(opt_types[opt_idx2]) {
	case OPT_TYPE_FD:
		val_len = sizeof(fd_val);
		err_idx2 = zmq_getsockopt(this_idx1, opt_idx2, &fd_val, &val_len);
		if(0 == err_idx2) {
			lua_pushinteger(L, (lua_Integer)fd_val);
			return 1;
		}
		break;
	case OPT_TYPE_INT:
		val_len = sizeof(int_val);
		err_idx2 = zmq_getsockopt(this_idx1, opt_idx2, &int_val, &val_len);
		if(0 == err_idx2) {
			lua_pushinteger(L, (lua_Integer)int_val);
			return 1;
		}
		break;
	case OPT_TYPE_UINT32:
		val_len = sizeof(uint32_val);
		err_idx2 = zmq_getsockopt(this_idx1, opt_idx2, &uint32_val, &val_len);
		if(0 == err_idx2) {
			lua_pushinteger(L, (lua_Integer)uint32_val);
			return 1;
		}
		break;
	case OPT_TYPE_UINT64:
		val_len = sizeof(uint64_val);
		err_idx2 = zmq_getsockopt(this_idx1, opt_idx2, &uint64_val, &val_len);
		if(0 == err_idx2) {
			lua_pushinteger(L, (lua_Integer)uint64_val);
			return 1;
		}
		break;
	case OPT_TYPE_INT64:
		val_len = sizeof(int64_val);
		err_idx2 = zmq_getsockopt(this_idx1, opt_idx2, &int64_val, &val_len);
		if(0 == err_idx2) {
			lua_pushinteger(L, (lua_Integer)int64_val);
			return 1;
		}
		break;
	case OPT_TYPE_STR:
		val_len = STR_MAX;
		err_idx2 = zmq_getsockopt(this_idx1, opt_idx2, str_val, &val_len);
		if(0 == err_idx2) {
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

  is_error = (0 != err_idx2);
  error_code__ZMQ_Error__push(L, err_idx2);
  return 2;
}

/* method: send */
static int ZMQ_Socket__send__meth(lua_State *L) {
  int is_error = 0;
  ZMQ_Socket * this_idx1 = obj_type_ZMQ_Socket_check(L,1);
  size_t data_idx2_len;
  const char * data_idx2 = luaL_checklstring(L,2,&(data_idx2_len));
  int flags_idx3 = luaL_optinteger(L,3,0);
  ZMQ_Error err_idx1 = 0;
	zmq_msg_t msg;
	/* initialize message */
	err_idx1 = zmq_msg_init_size(&msg, data_idx2_len);
	if(0 == err_idx1) {
		/* fill message */
		memcpy(zmq_msg_data(&msg), data_idx2, data_idx2_len);
		/* send message */
		err_idx1 = zmq_send(this_idx1, &msg, flags_idx3);
		/* close message */
		zmq_msg_close(&msg);
	}

  is_error = (0 != err_idx1);
  if(is_error) {
    lua_pushnil(L);
      error_code__ZMQ_Error__push(L, err_idx1);
  } else {
    lua_pushboolean(L, 1);
    lua_pushnil(L);
  }
  return 2;
}

/* method: recv */
static int ZMQ_Socket__recv__meth(lua_State *L) {
  int is_error = 0;
  ZMQ_Socket * this_idx1 = obj_type_ZMQ_Socket_check(L,1);
  int flags_idx2 = luaL_optinteger(L,2,0);
  size_t data_idx1_len = 0;
  const char * data_idx1 = NULL;
  ZMQ_Error err_idx2 = 0;
	zmq_msg_t msg;
	/* initialize message */
	err_idx2 = zmq_msg_init(&msg);
	if(0 == err_idx2) {
		/* receive message */
		err_idx2 = zmq_recv(this_idx1, &msg, flags_idx2);
		if(0 == err_idx2) {
			data_idx1 = zmq_msg_data(&msg);
			data_idx1_len = zmq_msg_size(&msg);
		}
	}

  is_error = (0 != err_idx2);
  if(is_error) {
    lua_pushnil(L);
  } else {
    if(data_idx1 == NULL) lua_pushnil(L);  else lua_pushlstring(L, data_idx1,data_idx1_len);
  }
  error_code__ZMQ_Error__push(L, err_idx2);
	/* close message */
	zmq_msg_close(&msg);

  return 2;
}



static const luaL_reg obj_ZMQ_Ctx_pub_funcs[] = {
  {NULL, NULL}
};

static const luaL_reg obj_ZMQ_Ctx_methods[] = {
  {"term", ZMQ_Ctx__term__meth},
  {"socket", ZMQ_Ctx__socket__meth},
  {NULL, NULL}
};

static const luaL_reg obj_ZMQ_Ctx_metas[] = {
  {"__gc", ZMQ_Ctx__term__meth},
  {"__tostring", obj_udata_default_tostring},
  {"__eq", obj_udata_default_equal},
  {NULL, NULL}
};

static const obj_base obj_ZMQ_Ctx_bases[] = {
  {-1, NULL}
};

static const obj_field obj_ZMQ_Ctx_fields[] = {
  {NULL, 0, 0, 0}
};

static const obj_const obj_ZMQ_Ctx_constants[] = {
  {NULL, NULL, 0.0 , 0}
};

static const luaL_reg obj_ZMQ_Socket_pub_funcs[] = {
  {NULL, NULL}
};

static const luaL_reg obj_ZMQ_Socket_methods[] = {
  {"close", ZMQ_Socket__close__meth},
  {"bind", ZMQ_Socket__bind__meth},
  {"connect", ZMQ_Socket__connect__meth},
  {"setopt", ZMQ_Socket__setopt__meth},
  {"getopt", ZMQ_Socket__getopt__meth},
  {"send", ZMQ_Socket__send__meth},
  {"recv", ZMQ_Socket__recv__meth},
  {NULL, NULL}
};

static const luaL_reg obj_ZMQ_Socket_metas[] = {
  {"__gc", ZMQ_Socket__close__meth},
  {"__tostring", obj_udata_default_tostring},
  {"__eq", obj_udata_default_equal},
  {NULL, NULL}
};

static const obj_base obj_ZMQ_Socket_bases[] = {
  {-1, NULL}
};

static const obj_field obj_ZMQ_Socket_fields[] = {
  {NULL, 0, 0, 0}
};

static const obj_const obj_ZMQ_Socket_constants[] = {
  {NULL, NULL, 0.0 , 0}
};

static const luaL_reg zmq_function[] = {
  {"version", zmq__version__func},
  {"init", zmq__init__func},
  {"device", zmq__device__func},
  {NULL, NULL}
};

static const obj_const zmq_constants[] = {
  {"TYPE", NULL, 16, CONST_NUMBER},
  {"RCVMORE", NULL, 13, CONST_NUMBER},
  {"LINGER", NULL, 17, CONST_NUMBER},
  {"REP", NULL, 4, CONST_NUMBER},
  {"MSG_SHARED", NULL, 128, CONST_NUMBER},
  {"SNDBUF", NULL, 11, CONST_NUMBER},
  {"MAX_VSM_SIZE", NULL, 30, CONST_NUMBER},
  {"NOBLOCK", NULL, 1, CONST_NUMBER},
  {"RCVBUF", NULL, 12, CONST_NUMBER},
  {"FORWARDER", NULL, 2, CONST_NUMBER},
  {"RATE", NULL, 8, CONST_NUMBER},
  {"IDENTITY", NULL, 5, CONST_NUMBER},
  {"SUB", NULL, 2, CONST_NUMBER},
  {"FD", NULL, 14, CONST_NUMBER},
  {"PUB", NULL, 1, CONST_NUMBER},
  {"DELIMITER", NULL, 31, CONST_NUMBER},
  {"EVENTS", NULL, 15, CONST_NUMBER},
  {"SNDMORE", NULL, 2, CONST_NUMBER},
  {"AFFINITY", NULL, 4, CONST_NUMBER},
  {"QUEUE", NULL, 3, CONST_NUMBER},
  {"POLLERR", NULL, 4, CONST_NUMBER},
  {"STREAMER", NULL, 1, CONST_NUMBER},
  {"RECOVERY_IVL", NULL, 9, CONST_NUMBER},
  {"HWM", NULL, 1, CONST_NUMBER},
  {"POLLIN", NULL, 1, CONST_NUMBER},
  {"REQ", NULL, 3, CONST_NUMBER},
  {"BACKLOG", NULL, 19, CONST_NUMBER},
  {"XREQ", NULL, 5, CONST_NUMBER},
  {"SWAP", NULL, 3, CONST_NUMBER},
  {"PUSH", NULL, 8, CONST_NUMBER},
  {"PAIR", NULL, 0, CONST_NUMBER},
  {"VSM", NULL, 32, CONST_NUMBER},
  {"XREP", NULL, 6, CONST_NUMBER},
  {"SUBSCRIBE", NULL, 6, CONST_NUMBER},
  {"PULL", NULL, 7, CONST_NUMBER},
  {"MCAST_LOOP", NULL, 10, CONST_NUMBER},
  {"MSG_MORE", NULL, 1, CONST_NUMBER},
  {"RECONNECT_IVL", NULL, 18, CONST_NUMBER},
  {"POLLOUT", NULL, 2, CONST_NUMBER},
  {"UNSUBSCRIBE", NULL, 7, CONST_NUMBER},
  {NULL, NULL, 0.0 , 0}
};



static const reg_sub_module reg_sub_modules[] = {
  { &(obj_type_ZMQ_Ctx), 0, obj_ZMQ_Ctx_pub_funcs, obj_ZMQ_Ctx_methods, obj_ZMQ_Ctx_metas, obj_ZMQ_Ctx_bases, obj_ZMQ_Ctx_fields, obj_ZMQ_Ctx_constants},
  { &(obj_type_ZMQ_Socket), 0, obj_ZMQ_Socket_pub_funcs, obj_ZMQ_Socket_methods, obj_ZMQ_Socket_metas, obj_ZMQ_Socket_bases, obj_ZMQ_Socket_fields, obj_ZMQ_Socket_constants},
  {NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL}
};







static const luaL_Reg submodule_libs[] = {
  {NULL, NULL}
};



static void create_object_instance_cache(lua_State *L) {
	lua_pushlightuserdata(L, obj_udata_weak_ref_key); /* key for weak table. */
	lua_rawget(L, LUA_REGISTRYINDEX);  /* check if weak table exists already. */
	if(!lua_isnil(L, -1)) {
		lua_pop(L, 1); /* pop weak table. */
		return;
	}
	lua_pop(L, 1); /* pop nil. */
	/* create weak table for object instance references. */
	lua_pushlightuserdata(L, obj_udata_weak_ref_key); /* key for weak table. */
	lua_newtable(L);               /* weak table. */
	lua_newtable(L);               /* metatable for weak table. */
	lua_pushliteral(L, "__mode");
	lua_pushliteral(L, "v");
	lua_rawset(L, -3);             /* metatable.__mode = 'v'  weak values. */
	lua_setmetatable(L, -2);       /* add metatable to weak table. */
	lua_rawset(L, LUA_REGISTRYINDEX);  /* create reference to weak table. */
}

int luaopen_zmq(lua_State *L) {
	const reg_sub_module *reg = reg_sub_modules;
	const luaL_Reg *submodules = submodule_libs;
	/* module table. */
	luaL_register(L, "zmq", zmq_function);

	/* register module constants. */
	obj_type_register_constants(L, zmq_constants, -1);

	/* create object cache. */
	create_object_instance_cache(L);

	for(; submodules->func != NULL ; submodules++) {
		lua_pushcfunction(L, submodules->func);
		lua_pushstring(L, submodules->name);
		lua_call(L, 1, 0);
	}

	/* register objects */
	for(; reg->type != NULL ; reg++) {
		lua_newtable(L); /* create public API table for object. */
		lua_pushvalue(L, -1); /* dup. object's public API table. */
		lua_setfield(L, -3, reg->type->name); /* module["<object_name>"] = <object public API> */
#if REG_OBJECTS_AS_GLOBALS
		lua_pushvalue(L, -1);                 /* dup value. */
		lua_setglobal(L, reg->type->name);    /* global: <object_name> = <object public API> */
#endif
		obj_type_register(L, reg);
	}

#if LUAJIT_FFI
	nobj_try_loading_ffi(L, zmq_ffi_lua_code);
#endif
	return 1;
}


