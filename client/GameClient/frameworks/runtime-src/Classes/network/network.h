/*******************************************************************
**		
** author : xzben 2014/12/09
** 客户端网络数据通信功能封装
*******************************************************************/

#ifndef __2014_12_09_NETWORK_H__
#define __2014_12_09_NETWORK_H__


#include "cocos2d.h"
#include <thread>
#include <queue>
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
	#include <fcntl.h>
	#include <arpa/inet.h>
	#include <netinet/in.h>
	#include <unistd.h>
	#include <errno.h>
	typedef int					int32;
	typedef int					SOCKET_HANDLE;
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
    #include <sys/socket.h>
    #include <sys/types.h>
    #include <sys/select.h>
    //#include <sys/epoll.h>
    #include <fcntl.h>
    #include <arpa/inet.h>
    #include <netinet/in.h>
    #include <unistd.h>
    #include <errno.h>
    typedef int					int32;
    typedef int					SOCKET_HANDLE;
#endif//平台相关


#include "packet.h"
#include "Mutex.h"

enum NETSTATE
{
	DISCONNECT  = 0,
	CONNECTING  = 1,
	SUCCESS     = 2,
	FAILED      = 3,
};

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

class CCNetwork : public cocos2d::CCObject
{
public:
	CCNetwork();
	~CCNetwork();
	bool	init();
	void	update(float delta);
	int		connect(const char* host, short port, int timeval = 1000);
	int		send_msg(PacketBuffer* buf);
	void	register_lua_callback(int state_ref, int msg_ref);
	int		get_state_callback() { return m_lua_state_callback;  }
	int		get_msg_callback(){ return m_lua_msg_callback; }
protected:
	static void	socketThreadFunc(void* param);

	void	reset();
	void	push_status(int state);
private:
	TCPSocket		 m_socket;
	typedef std::queue<PacketBuffer*>	PacketQueue;
	PacketQueue		 m_sendPackets;
	Mutex			 m_send_lock;
	PacketQueue		 m_recvPackets;
	Mutex			 m_recv_lock;
	std::queue<int>  m_status;
	Mutex			 m_status_lock;
	std::thread		 *m_recvThread;
	Condition		 m_recvThreadCond;
	bool			 m_close;
	bool			 m_bConnected;
	char			 m_szHost[20];
	short			 m_port;
	int				 m_lua_state_callback;
	int				 m_lua_msg_callback;
};
#endif//__2014_12_09_PACKET_H__