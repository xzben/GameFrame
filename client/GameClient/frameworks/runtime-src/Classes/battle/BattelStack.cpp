#include "BattleStack.h"



#include "tolua_fix.h"
extern "C" {
#include "lua.h"
#include "tolua++.h"
#include "lualib.h"
#include "lauxlib.h"
}

#include "LuaBasicConversions.h"

namespace {
	int lua_print(lua_State * luastate)
	{
		int nargs = lua_gettop(luastate);

		std::string t;
		for (int i = 1; i <= nargs; i++)
		{
			if (lua_istable(luastate, i))
				t += "table";
			else if (lua_isnone(luastate, i))
				t += "none";
			else if (lua_isnil(luastate, i))
				t += "nil";
			else if (lua_isboolean(luastate, i))
			{
				if (lua_toboolean(luastate, i) != 0)
					t += "true";
				else
					t += "false";
			}
			else if (lua_isfunction(luastate, i))
				t += "function";
			else if (lua_islightuserdata(luastate, i))
				t += "lightuserdata";
			else if (lua_isthread(luastate, i))
				t += "thread";
			else
			{
				const char * str = lua_tostring(luastate, i);
				if (str)
					t += lua_tostring(luastate, i);
				else
					t += lua_typename(luastate, lua_type(luastate, i));
			}
			if (i != nargs)
				t += "\t";
		}
		CCLOG("[LUA-print] %s", t.c_str());

		return 0;
	}

	int lua_release_print(lua_State * L)
	{
		int nargs = lua_gettop(L);

		std::string t;
		for (int i = 1; i <= nargs; i++)
		{
			if (lua_istable(L, i))
				t += "table";
			else if (lua_isnone(L, i))
				t += "none";
			else if (lua_isnil(L, i))
				t += "nil";
			else if (lua_isboolean(L, i))
			{
				if (lua_toboolean(L, i) != 0)
					t += "true";
				else
					t += "false";
			}
			else if (lua_isfunction(L, i))
				t += "function";
			else if (lua_islightuserdata(L, i))
				t += "lightuserdata";
			else if (lua_isthread(L, i))
				t += "thread";
			else
			{
				const char * str = lua_tostring(L, i);
				if (str)
					t += lua_tostring(L, i);
				else
					t += lua_typename(L, lua_type(L, i));
			}
			if (i != nargs)
				t += "\t";
		}
		log("[LUA-print] %s", t.c_str());

		return 0;
	}
}

extern "C"
{
	int cocos2dx_lua_battle_loader(lua_State *L)
	{
		static const std::string BYTECODE_FILE_EXT = ".luac";
		static const std::string NOT_BYTECODE_FILE_EXT = ".lua";

		std::string filename(luaL_checkstring(L, 1));
		size_t pos = filename.rfind(BYTECODE_FILE_EXT);
		if (pos != std::string::npos)
		{
			filename = filename.substr(0, pos);
		}
		else
		{
			pos = filename.rfind(NOT_BYTECODE_FILE_EXT);
			if (pos == filename.length() - NOT_BYTECODE_FILE_EXT.length())
			{
				filename = filename.substr(0, pos);
			}
		}

		pos = filename.find_first_of(".");
		while (pos != std::string::npos)
		{
			filename.replace(pos, 1, "/");
			pos = filename.find_first_of(".");
		}

		// search file in package.path
		unsigned char* chunk = nullptr;
		ssize_t chunkSize = 0;
		std::string chunkName;
		FileUtils* utils = FileUtils::getInstance();

		lua_getglobal(L, "package");
		lua_getfield(L, -1, "path");
		std::string searchpath(lua_tostring(L, -1));
		lua_pop(L, 1);
		size_t begin = 0;
		size_t next = searchpath.find_first_of(";", 0);

		do
		{
			if (next == std::string::npos)
				next = searchpath.length();
			std::string prefix = searchpath.substr(begin, next);
			if (prefix[0] == '.' && prefix[1] == '/')
			{
				prefix = prefix.substr(2);
			}

			pos = prefix.find("?.lua");
			chunkName = prefix.substr(0, pos) + filename + BYTECODE_FILE_EXT;
			if (utils->isFileExist(chunkName))
			{
				chunk = utils->getFileData(chunkName.c_str(), "rb", &chunkSize);
				break;
			}
			else
			{
				chunkName = prefix.substr(0, pos) + filename + NOT_BYTECODE_FILE_EXT;
				if (utils->isFileExist(chunkName))
				{
					chunk = utils->getFileData(chunkName.c_str(), "rb", &chunkSize);
					break;
				}
			}

			begin = next + 1;
			next = searchpath.find_first_of(";", begin);
		} while (begin < (int)searchpath.length());

		if (chunk)
		{
			LuaStack* stack = BattleStack::getInstance();
			stack->luaLoadBuffer(L, (char*)chunk, (int)chunkSize, chunkName.c_str());
			free(chunk);
		}
		else
		{
			CCLOG("can not get file data of %s", chunkName.c_str());
			return 0;
		}

		return 1;
	}
}

BattleStack* BattleStack::s_instance = nullptr;

BattleStack* BattleStack::getInstance()
{
	if (s_instance == nullptr)
	{
		s_instance = new BattleStack();
	}

	return s_instance;
}

BattleStack::BattleStack()
: m_pause(false)
{
	_state = lua_open();
	luaL_openlibs(_state);

	// Register our version of the global "print" function
	const luaL_reg global_functions[] = {
		{ "print", lua_print },
		{ "release_print", lua_release_print },
		{ nullptr, nullptr }
	};
	luaL_register(_state, "_G", global_functions);

	// add cocos2dx loader
	addLuaLoader(cocos2dx_lua_battle_loader);
	luaopen_battleStack_c(_state);
}

BattleStack::~BattleStack()
{
}


bool BattleStack::reset(const char* filename, const char* funcname)
{
	this->executeScriptFile(filename);
	this->executeGlobalFunction(funcname);

	return true;
}

void BattleStack::pause(bool yield)
{
	m_pause = true;
	if (yield)
		m_condition.wait();
}

void BattleStack::resume()
{
	m_pause = false;
	m_condition.notify_all();
}

bool BattleStack::isPause()
{
	return m_pause;
}

int BattleStack::run(std::string functionName)
{
	std::thread thrd([=](){
		{
			this->executeGlobalFunction(functionName.c_str());
		}
	});

	thrd.detach();

	return 0;
}

//view use
void BattleStack::popOutputMessage(ValueVector& messages)
{
	m_outputLock.lock();

	messages.swap(m_outputMessage);

	m_outputLock.unlock();
}

void  BattleStack::pushInputMessage(ValueVector& messages)
{
	m_inputLock.lock();
	m_inputMessage.insert(m_inputMessage.end(), messages.begin(), messages.end());
	m_inputLock.unlock();
}


//battle use
void  BattleStack::popInputMessage(ValueVector& messages)
{
	m_inputLock.lock();
	messages.swap(m_inputMessage);
	m_inputLock.unlock();
}

void BattleStack::pushOutputMessage(ValueVector& messages)
{
	m_outputLock.lock();
	m_outputMessage.insert(m_outputMessage.end(), messages.begin(), messages.end());
	m_outputLock.unlock();
}

#define OBJ_TYPE_NAME						"battlestack.object"
#define LUA_TABLE_NAME						"BattleStack"
#define REGISTER_AND_SETMETATABLE(L, l)			do{ luaL_register(L, LUA_TABLE_NAME, l); luaL_newmetatable(L, OBJ_TYPE_NAME); lua_pushstring(L, "__index"); lua_getglobal(L, LUA_TABLE_NAME); lua_settable(L, -3); } while (0)
#define check_battlestack_obj(L, index)			(*((BattleStack**)luaL_checkudata((L), (index), OBJ_TYPE_NAME)))
#define set_battlestack_obj_flag(L)				do{ luaL_getmetatable((L), OBJ_TYPE_NAME);lua_setmetatable((L), -2); }while(0)

static int c_get_battle_stack_instance(lua_State* L)
{
	BattleStack **obj = (BattleStack**)lua_newuserdata(L, sizeof(BattleStack*));
	*obj = BattleStack::getInstance();
	set_battlestack_obj_flag(L);

	return 1;
}

static int c_pause_battle_stack_instance(lua_State* L)
{
	int argc = lua_gettop(L) - 1;
	BattleStack* obj = check_battlestack_obj(L, 1);
	if (obj == nullptr)
	{
		luaL_error(L, "invalid battleStack Obj");
		return 0;
	}
	if (argc == 0)
	{
		obj->pause();
	}
	else
	{
		bool yield = lua_toboolean(L, 2);
		obj->pause(yield);
	}
	
	return 1;
}

static int c_resume_battle_stack_instance(lua_State* L)
{
	BattleStack* obj = check_battlestack_obj(L, 1);
	if (obj == nullptr)
	{
		luaL_error(L, "invalid battleStack Obj");
		return 0;
	}
	obj->resume();
	return 1;
}

static int c_is_pause_battle_stack_instance(lua_State* L)
{
	BattleStack* obj = check_battlestack_obj(L, 1);
	if (obj == nullptr)
	{
		luaL_error(L, "invalid battleStack Obj");
		return 0;
	}

	bool isPause = obj->isPause();

	lua_pushboolean(L, isPause);

	return 1;
}

static int c_reset_battle_stack_instance(lua_State* L)
{
	BattleStack* obj = check_battlestack_obj(L, 1);
	if (obj == nullptr)
	{
		luaL_error(L, "invalid battleStack Obj");
		return 0;
	}

	const char* filename = luaL_checkstring(L, 2);
	const char* funcName = luaL_checkstring(L, 3);
	obj->reset(filename, funcName);
	return 1;
}

static int c_run_battle_stack_instance(lua_State* L)
{
	BattleStack* obj = check_battlestack_obj(L, 1);
	if (obj == nullptr)
	{
		luaL_error(L, "invalid battleStack Obj");
		return 0;
	}

	const char* functionname = luaL_checkstring(L, 2);
	obj->run(functionname);
	return 1;
}

static int c_push_input_messages_battle_stack_instance(lua_State* L)
{
	int top = lua_gettop(L);
	if (top < 2)
	{
		luaL_error(L, "args number error, need a table param");
		return 0;
	}
	BattleStack* obj = check_battlestack_obj(L, 1);
	if (obj == nullptr)
	{
		luaL_error(L, "invalid battleStack Obj");
		return 0;
	}

	if (!lua_istable(L, 2))
	{
		luaL_error(L, "param type error, need a table param ");
		return 0;
	}

	ValueVector ret;
	bool ok = luaval_to_ccvaluevector(L, 2, &ret, "c_push_input_messages_battle_stack_instance");
	if (!ok)
	{
		luaL_error(L, "the intput table convert to ValueVetor error!");
		return 0;
	}

	obj->pushInputMessage(ret);


	return 1;
}

static int c_push_output_messages_battle_stack_instance(lua_State* L)
{
	int top = lua_gettop(L);
	if (top < 2)
	{
		luaL_error(L, "args number error, need a table param");
		return 0;
	}
	BattleStack* obj = check_battlestack_obj(L, 1);
	if (obj == nullptr)
	{
		luaL_error(L, "invalid battleStack Obj");
		return 0;
	}

	if (!lua_istable(L, 2))
	{
		luaL_error(L, "param type error, need a table param ");
		return 0;
	}

	ValueVector ret;

	if (!luaval_to_ccvaluevector(L, 2, &ret, "c_push_output_messages_battle_stack_instance"))
	{
		luaL_error(L, "the intput table convert to ValueVetor error!");
		return 0;
	}

	obj->pushOutputMessage(ret);
	return 1;
}

static int c_pop_input_messages_battle_stack_instance(lua_State* L)
{
	BattleStack* obj = check_battlestack_obj(L, 1);
	if (obj == nullptr)
	{
		luaL_error(L, "invalid battleStack Obj");
		return 0;
	}
	ValueVector ret;
	obj->popInputMessage(ret);

	ccvaluevector_to_luaval(L, ret);

	return 1;
}

static int c_pop_output_messages_battle_stack_instance(lua_State* L)
{
	BattleStack* obj = check_battlestack_obj(L, 1);
	if (obj == nullptr)
	{
		luaL_error(L, "invalid battleStack Obj");
		return 0;
	}
	ValueVector ret;
	obj->popOutputMessage(ret);

	ccvaluevector_to_luaval(L, ret);

	return 1;
}


int luaopen_battleStack_c(lua_State *L)
{
	static luaL_Reg lib[] = {
		{ "pause", c_pause_battle_stack_instance },
		{ "resume", c_resume_battle_stack_instance },
		{ "isPause", c_is_pause_battle_stack_instance },
		{ "reset", c_reset_battle_stack_instance },
		{ "run", c_run_battle_stack_instance },
		{ "getInstance", c_get_battle_stack_instance},
		{ "pushInputMessages", c_push_input_messages_battle_stack_instance },
		{ "pushOutputMessages", c_push_output_messages_battle_stack_instance },
		{ "popInputMessages", c_pop_input_messages_battle_stack_instance },
		{ "popOutputMessages", c_pop_output_messages_battle_stack_instance },


		{ NULL, NULL },
	};

	REGISTER_AND_SETMETATABLE(L, lib);

	return 1;
}