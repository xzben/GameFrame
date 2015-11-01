#include "ResourceEncrypt.h"
#include <cstdlib>
#include <cstring>
#include <cstdio>
#include <cctype>
#include <algorithm>

ResourceEncrypt::ResourceEncrypt()
: m_encryptkey(NULL)
, m_encryptSign(NULL)
, m_isEncrypt(false)
, m_keyIndex(0)
{

}

bool ResourceEncrypt::checkEncryptSign(const char* buffer, int size)
{
	if (size < m_signLen || strncmp(buffer, m_encryptSign, m_signLen) != 0)
		return false;

	return true;
}

bool ResourceEncrypt::isNeedEncrypt(std::string filepath)
{
	const char* sEncryptFiles[] = {
		"png",
		"jpg",
		"lua",
		NULL
	};

	std::string::size_type pos = filepath.rfind(".");
	if (!m_isEncrypt || pos == std::string::npos)
	{
		return false;
	}

	std::string extension = filepath.substr(pos);
	transform(extension.begin(), extension.end(), extension.begin(), tolower);

	for (int i = 0; sEncryptFiles[i] != NULL; i++)
	{
		std::string needFile = sEncryptFiles[i];
		if (extension == ("." + needFile))
		{
			return true;
		}
	}

	return false;
}

bool ResourceEncrypt::checkEncryptFile(const char* filepath)
{
	if (!isNeedEncrypt(filepath))
		return true;

	return encryptFile(filepath);
}

bool ResourceEncrypt::checkDecryptFile(const char* filepath)
{
	if (!isNeedEncrypt(filepath))
		return true;

	return decryptFile(filepath);
}

bool ResourceEncrypt::checkDecrypt(unsigned char* source, int sourceSize, unsigned char*& outbuf, int &outSize, const char* filepath)
{
	char* head = (char*)source;
	outbuf = source;
	outSize = sourceSize;
	if (!isNeedEncrypt(filepath) || !checkEncryptSign(head, sourceSize))
		return true;

	outbuf = source + m_signLen;
	outSize = sourceSize - m_signLen;
	m_keyIndex = 0;
	return decrypt(outbuf, outSize);
}

void  ResourceEncrypt::setEncrypt(const char* key, const int keyLen, const char* sign, const int signLen)
{
	m_encryptkey = key;
	m_keyLen = keyLen;
	m_encryptSign = sign;
	m_signLen = signLen;

	if (m_signLen > 0 && m_keyLen > 0)
	{
		m_isEncrypt = true;
	}
}

bool ResourceEncrypt::encryptFile(const char* filepath)
{
	bool ret = false;
	m_keyIndex = 0;
	std::string tempFile = filepath;
	tempFile += ".enTmp";

	FILE *fp = fopen(filepath, "rb");
	FILE *wFp = fopen(tempFile.c_str(), "wb");
	do
	{
		if (NULL == fp || wFp == NULL) break;

		unsigned char buffer[512];
		int keyIndex = 0;

		fwrite(m_encryptSign, sizeof(unsigned char), m_signLen, wFp);
		while (feof(fp) == 0)
		{
			int readSize = fread(buffer, sizeof(unsigned char), 512, fp);
			encrypt(buffer, readSize);
			fwrite(buffer, sizeof(unsigned char), readSize, wFp);
		}
		ret = true;
	} while (0);

	if (NULL != fp)  fclose(fp);
	if (NULL != wFp) fclose(wFp);

	if (ret)
	{
		remove(filepath);
		rename(tempFile.c_str(), filepath);
	}

	return ret;
}


bool ResourceEncrypt::decryptFile(const char* filepath)
{
	bool ret = false;
	FILE *rFp = NULL;
	FILE *wFp = NULL;
	std::string tempFile = filepath;
	tempFile += ".deTmp";
	m_keyIndex = 0;
	do
	{
		rFp = fopen(filepath, "rb");
		if (NULL == rFp) break;
		const int buffSize = m_signLen > 512 ? m_signLen : 512;
		unsigned char *buffer = (unsigned char*)malloc(sizeof(unsigned char)*buffSize);

		int count = 0;
		while (feof(rFp) == 0)
		{
			if (count >= m_signLen) break;
			int readSize = fread(buffer + count, sizeof(unsigned char), m_signLen - count, rFp);
			count += readSize;
		}
		if (!checkEncryptSign((char*)buffer, count))
			break;

		wFp = fopen(tempFile.c_str(), "wb");
		if (NULL == rFp) break;

		while (feof(rFp) == 0)
		{
			int readSize = fread(buffer, sizeof(unsigned char), buffSize, rFp);
			decrypt(buffer, readSize);
			fwrite(buffer, sizeof(unsigned char), readSize, wFp);
		}

		ret = true;

	} while (0);

	if (NULL != rFp) fclose(rFp);
	if (NULL != wFp) fclose(wFp);
	if (ret)
	{
		remove(filepath);
		rename(tempFile.c_str(), filepath);
	}
	return ret;
}


bool ResourceEncrypt::encrypt(unsigned char* source, int sourceSize)
{
	for (int i = 0; i < sourceSize; i++)
	{
		source[i] = source[i] ^ (unsigned char)m_encryptkey[m_keyIndex];
		m_keyIndex = (m_keyIndex + 1) % m_keyLen;
	}

	return true;
}

bool ResourceEncrypt::decrypt(unsigned char* source, int sourceSize)
{
	for (int i = 0; i < sourceSize; i++)
	{
		source[i] = source[i] ^ (unsigned char)m_encryptkey[m_keyIndex];
		m_keyIndex = (m_keyIndex + 1) % m_keyLen;
	}

	return true;
}

