#ifndef __2016_01_15_BaTTLE_STACK_H__
#define __2016_01_15_BaTTLE_STACK_H__
#include "cocos2d.h"
#include "CCLuaStack.h"
#include "CCFileUtils.h"
#include "network/Mutex.h"

USING_NS_CC;

class BattleStack : public LuaStack
{
public:
	static BattleStack* getInstance();
	BattleStack();
	~BattleStack();

	bool reset(const char* filename, const char* funcname);
	int run(std::string functionName);
	bool isPause();

	//view use
	void  popOutputMessage(ValueVector& messages);
	void  pushInputMessage(ValueVector& messages);
	

	//battle use
	void  popInputMessage(ValueVector& messages);
	void  pushOutputMessage(ValueVector& messages);

	void pause(bool yield = false);
	void resume();
protected:
	volatile bool m_pause;
	Mutex				   m_inputLock;
	ValueVector			   m_inputMessage;
	Mutex				   m_outputLock;
	ValueVector			   m_outputMessage;
	Condition			   m_condition;
protected:
	static BattleStack*  s_instance;
};

int luaopen_battleStack_c(lua_State *L);
#endif//__2016_01_15_BaTTLE_STACK_H__