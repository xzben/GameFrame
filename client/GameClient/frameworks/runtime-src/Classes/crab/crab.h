#ifndef __2014_10_17_CRAB_H__
#define __2014_10_17_CRAB_H__

extern "C"{
#include "lua.h"
#include "lauxlib.h"
}

int luaopen_utf8_c(lua_State *L);
int luaopen_crab_c(lua_State *L);

#endif//__2014_10_17_CRAB_H__