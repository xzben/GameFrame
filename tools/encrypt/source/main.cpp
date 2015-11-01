#include "ResourceEncrypt.h"
#include <cstring>

int main(int argc, char* argv[])
{
	if (argc < 4)
	{
		printf("使用说明: (E|D) 加密秘钥字符串  加密标记字符串   文件路径\n");
		printf("          E 加密 D 解密");
		return 0;
	}

	bool isEncrpt = false;
	char* key = NULL;
	int keyLen = 0;
	char* sign = NULL;
	int signLen = 0;
	char* filepath = NULL;

	isEncrpt = strcmp(argv[1], "E") == 0;
	key = argv[2];
	sign = argv[3];
	filepath = argv[4];

	ResourceEncrypt  encrypt;
	encrypt.setEncrypt(key, strlen(key), sign, strlen(sign));
	
	if (isEncrpt)
		encrypt.checkEncryptFile(filepath);
	else
		encrypt.checkDecryptFile(filepath);
}