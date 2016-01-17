#ifndef __2016_01_15_BATTLE_FILE_UTILS_H__
#define __2016_01_15_BATTLE_FILE_UTILS_H__
#include "cocos2d.h"
#include "CCLuaStack.h"
#include "CCFileUtils.h"
USING_NS_CC;

class BattleFileUtil : public FileUtils
{
public:
	static FileUtils* getInstance();
	static void destroyInstance();

	virtual std::string getStringFromFile(const std::string& filename);
	virtual Data getDataFromFile(const std::string& filename);
	virtual unsigned char* getFileDataFromZip(const std::string& zipFilePath, const std::string& filename, ssize_t *size);
	virtual std::string fullPathForFilename(const std::string &filename);
	virtual void loadFilenameLookupDictionaryFromFile(const std::string &filename);
	virtual void setFilenameLookupDictionary(const ValueMap& filenameLookupDict);
	virtual std::string fullPathFromRelativeFile(const std::string &filename, const std::string &relativeFile);
	virtual void setSearchResolutionsOrder(const std::vector<std::string>& searchResolutionsOrder);
	virtual void addSearchResolutionsOrder(const std::string &order, const bool front = false);
	virtual const std::vector<std::string>& getSearchResolutionsOrder() const;
	virtual void setSearchPaths(const std::vector<std::string>& searchPaths);
	void addSearchPath(const std::string & path, const bool front = false);
	virtual const std::vector<std::string>& getSearchPaths() const;
	virtual std::string getWritablePath() const = 0;
	virtual void setPopupNotify(bool notify);
	virtual bool isPopupNotify();
	virtual ValueMap getValueMapFromFile(const std::string& filename);
	virtual ValueMap getValueMapFromData(const char* filedata, int filesize);
	virtual bool writeToFile(ValueMap& dict, const std::string& fullPath);
	virtual ValueVector getValueVectorFromFile(const std::string& filename);
	virtual bool isFileExist(const std::string& filename) const;
	virtual bool isAbsolutePath(const std::string& path) const;
	virtual bool isDirectoryExist(const std::string& dirPath);
	virtual bool createDirectory(const std::string& dirPath);
	virtual bool removeDirectory(const std::string& dirPath);
	virtual bool removeFile(const std::string &filepath);
	virtual bool renameFile(const std::string &path, const std::string &oldname, const std::string &name);
	virtual long getFileSize(const std::string &filepath);

	/** Returns the full path cache */
	const std::unordered_map<std::string, std::string>& getFullPathCache() const { return _fullPathCache; }

protected:
	BattleFileUtil();
	virtual bool init();
	virtual std::string getNewFilename(const std::string &filename) const;
	virtual bool isFileExistInternal(const std::string& filename) const = 0;
	virtual bool isDirectoryExistInternal(const std::string& dirPath) const;
	virtual std::string getPathForFilename(const std::string& filename, const std::string& resolutionDirectory, const std::string& searchPath);
	virtual std::string getFullPathForDirectoryAndFilename(const std::string& directory, const std::string& filename);
	virtual std::string searchFullPathForFilename(const std::string& filename) const;


	static BattleFileUtil* s_sharedFileUtils;
};

#endif//__2016_01_15_BATTLE_FILE_UTILS_H__