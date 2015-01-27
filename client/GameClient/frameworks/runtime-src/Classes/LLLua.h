#ifndef __2015_01_24_LLLUA_H__
#define __2015_01_24_LLLUA_H__

#include <string.h>

extern "C" {
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
}

#include "tolua_fix.h"

#define luaLL_reffunction(L, idx) \
	toluafix_ref_function(L, (idx) > 0 ? (idx) : (lua_gettop(L) + 1 + idx), 0)

#define luaLL_unreffunction(L, ref) \
	toluafix_remove_function_by_refid(L, (ref))

#define luaLL_getreffunction(L, ref) \
	toluafix_get_function_by_refid(L, (ref))

#define luaLL_ref(L)        luaL_ref(L, LUA_REGISTRYINDEX)
#define luaLL_unref(L,ref)  luaL_unref(L, LUA_REGISTRYINDEX, (ref))
#define luaLL_getref(L,ref) lua_rawgeti(L, LUA_REGISTRYINDEX, (ref))

int luaLL_copyref(lua_State *L, int ref);

#endif // __2015_01_24_LLLUA_H__
