#include <stdio.h>
#include <assert.h>
#include <stdint.h>
#include "luaNetwork.h"
#include "network/network.h"
#include "tolua++.h"
#include "LLLua.h"

#define OBJ_TYPE_NAME						"network.object"
#define check_network_obj(L, index)			(*((CCNetwork**)luaL_checkudata((L), (index), OBJ_TYPE_NAME)))
#define set_network_obj_flag(L)				do{ luaL_getmetatable((L), OBJ_TYPE_NAME);lua_setmetatable((L), -2); }while(0)
		
static int c_new_network(lua_State* L)
{
	CCNetwork **network = (CCNetwork**)lua_newuserdata(L, sizeof(CCNetwork*));
	*network = new CCNetwork();
	set_network_obj_flag(L);

	return 1;
}

static int c_delete_network(lua_State* L)
{
	CCNetwork* network = check_network_obj(L, 1);

	int state_ref = network->get_msg_callback();
	int msg_ref = network->get_state_callback();

	luaLL_unreffunction(L, state_ref );
	luaLL_unreffunction(L, msg_ref);

	delete network;

	return 1;
}

static int c_connect(lua_State* L)
{
	CCNetwork* network = check_network_obj(L, 1);
	const char* strHost = luaL_checkstring(L, 2);
	int nPort = luaL_checknumber(L, 3);
	int wait_time = luaL_checknumber(L, 4);

	network->connect(strHost, nPort, wait_time);

	return 1;
}

static int c_send_message(lua_State* L)
{
	CCNetwork* network = check_network_obj(L, 1);
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
    size_t       all_size = 0;
#else
	unsigned int all_size = 0;
#endif
	const char* buffer = luaL_checklstring(L, 2, &all_size);
	int write_size = 0;

	while (write_size < all_size)
	{
		PacketBuffer *packet = new PacketBuffer;
		int free_size = packet->getFreeSize();
		int size = all_size-write_size;

		if (size > free_size)
			size = free_size;
		
		packet->FillData(size, (void*)&buffer[write_size]);
		network->send_msg(packet);
		write_size += size;
	}
	

	return 1;
}

static int c_register_callback(lua_State *L)
{
	CCNetwork* network = check_network_obj(L, 1);
	int state_ref = luaLL_reffunction(L, 2);
	int msg_ref = luaLL_reffunction(L, 3);

	network->register_lua_callback(state_ref, msg_ref);
	return 1;
}

int luaopen_network_c(lua_State *L) 
{
	luaL_Reg l[] = {
		{ "connect",			c_connect },
		{ "send_message",		c_send_message },
		{ "new_network",		c_new_network },
		{ "resiger_callback",	c_register_callback },
		{ NULL, NULL },
	};
	luaL_newmetatable(L, OBJ_TYPE_NAME);
	lua_pushcfunction(L, c_delete_network);
	lua_setfield(L,-2,"__gc");

	luaL_register(L, "CNetwork", l);
	return 1;
}