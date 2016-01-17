#include "BattleFileUtils.h"

BattleFileUtil* BattleFileUtil::s_sharedFileUtils = nullptr;

FileUtils* BattleFileUtil::getInstance()
{
	if (s_sharedFileUtils == nullptr)
	{
		s_sharedFileUtils = new BattleFileUtil();
		if (!s_sharedFileUtils->init())
		{
			delete s_sharedFileUtils;
			s_sharedFileUtils = nullptr;
			CCLOG("ERROR: Could not init BattleFileUtil");
		}
	}
	return s_sharedFileUtils;
}
void BattleFileUtil::destroyInstance()
{
	CC_SAFE_DELETE(s_sharedFileUtils);
}

std::string BattleFileUtil::getStringFromFile(const std::string& filename)
{
	return FileUtils::getInstance()->getStringFromFile(filename);
}

Data BattleFileUtil::getDataFromFile(const std::string& filename)
{

}