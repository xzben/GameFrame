#ifndef __2015_10_09_RESOURCE_ENCRYPT_H__
#define __2015_10_09_RESOURCE_ENCRYPT_H__

#include <string>

class ResourceEncrypt
{
public:
	ResourceEncrypt();
	void  setEncrypt(const char* key, const int keyLen, const char* sign, const int signLen);

	bool isNeedEncrypt(std::string filepath);
	bool checkEncryptSign(const char* buffer, int size);
	bool checkEncryptFile(const char* filepath);
	bool checkDecryptFile(const char* filepath);
	bool checkDecrypt(unsigned char* source, int sourceSize, unsigned char*& outbuf, int &outSize, const char* filepath);
private:
	
	bool encryptFile(const char* filepath);
	bool decryptFile(const char* filepath);
	bool encrypt(unsigned char* source, int sourceSize);
	bool decrypt(unsigned char* source, int sourceSize);
private:
	const  char*	m_encryptkey;
	int				m_keyLen;
	const  char*	m_encryptSign;
	int				m_signLen;
	bool			m_isEncrypt;
	int				m_keyIndex;
};
#endif//__2015_10_09_RESOURCE_ENCRYPT_H__