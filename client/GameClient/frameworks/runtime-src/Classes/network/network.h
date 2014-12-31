/*******************************************************************
**		
** author : xzben 2014/12/09
** 客户端网络数据通信功能封装
*******************************************************************/

#ifndef __2014_12_09_NETWORK_H__
#define __2014_12_09_NETWORK_H__



#include <thread>
//SOCKET 句柄类型
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	#include<winsock2.h>
	#include <MSWSock.h>
	#pragma comment(lib, "ws2_32.lib")
	#pragma comment ( lib, "mswsock.lib")
	typedef SOCKET					SOCKET_HANDLE;
	typedef int						socklen_t;
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_LINUX)
	#include <sys/socket.h>
	#include <sys/types.h>
	#include <sys/select.h>
	#include <sys/epoll.h>
	#include <arpa/inet.h>
	#include <netinet/in.h>
	#include <unistd.h>
	#include <errno.h>
	typedef int32					SOCKET_HANDLE;
#endif//平台相关

#include "cocos2d.h"
#include "packet.h"

class TCPSocket
{
public:
	TCPSocket();
	~TCPSocket();

	int		init();
	bool	set_unblock();
	/*
	** host 链接的地址
	** port 链接的端口
	** timeval 链接等待超时时间单位毫秒， 默认1000毫秒
	*/
	bool	connect(const char* host, short port, int timeval = 1000 );	
	int		recv_msg(void* buffer, int len);
	int		send_msg(void* buffer, int len);
	bool	close();
	void	get_status(bool *pReadReady = nullptr, bool* pWriteReady = nullptr, bool* pExceptReady = nullptr, int timeval = 1000);
private:
	SOCKET_HANDLE m_hSocket;
};

class CCNetwork : public cocos2d::CCNode
{
public:
	CCNetwork();
	~CCNetwork();
	bool	init() override;
	void	update(float delta) override;
	int		connect(const char* host, short port, int timeval = 1000);
	int		send_msg(PacketBuffer* buf);
protected:
	static void	recvThreadFunc(void* param);
private:
	TCPSocket		m_socket;	
	PacketQueue		m_sendPackets;
	PacketQueue		m_recvPackets;
	std::thread		*m_recvThread;
	Condition		m_recvThreadCond;
	bool			m_close;
	bool			m_bConnected;
	char			m_szHost[20];
	short			m_port;
};
#endif//__2014_12_09_PACKET_H__