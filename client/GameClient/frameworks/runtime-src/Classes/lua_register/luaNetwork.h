#ifndef __2015_01_24_LUA_NETWORK_H__
#define __2015_01_24_LUA_NETWORK_H__

extern "C"{
#include "lua.h"
#include "lauxlib.h"
}

int luaopen_network_c(lua_State *L);
#endif//__2015_01_24_LUA_NETWORK_H__