#ifndef __2015_01_26_LUA52_H__
#define __2015_01_26_LUA52_H__

extern "C"{
#include "lua.h"
#include "lauxlib.h"
}

#ifndef luaL_newlib /* using LuaJIT */
/*
** set functions from list 'l' into table at top - 'nup'; each
** function gets the 'nup' elements at the top as upvalues.
** Returns with only the table at the stack.
*/
LUALIB_API void luaL_setfuncs (lua_State *L, const luaL_Reg *l, int nup);

#define luaL_newlibtable(L,l) \
	lua_createtable(L, 0, sizeof(l)/sizeof((l)[0]) - 1)

#define luaL_newlib(L,l)  (luaL_newlibtable(L,l), luaL_setfuncs(L,l,0))
#endif

typedef unsigned int	lua_Unsigned;
typedef lua_Unsigned	b_uint;

/* test for pseudo index */
#define ispseudo(i)		((i) <= LUA_REGISTRYINDEX)
#define cast(t, exp)	((t)(exp))

#define cast_byte(i)	cast(lu_byte, (i))
#define cast_num(i)		cast(lua_Number, (i))
#define cast_int(i)		cast(int, (i))
#define cast_uchar(i)	cast(unsigned char, (i))


LUALIB_API int luaopen_utf8_c(lua_State *L);
LUALIB_API int luaopen_crab_c(lua_State *L);

extern "C" {
	LUALIB_API int luaopen_protobuf_c(lua_State *L);
}

#endif//__2015_01_26_LUA52_H__