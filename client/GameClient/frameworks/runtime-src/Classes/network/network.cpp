#include "network.h"
#include <assert.h>
#include <cstring>

TCPSocket::TCPSocket()
{
	m_hSocket = -1;
}

TCPSocket::~TCPSocket()
{
	this->close();
}

int		TCPSocket::init()
{
	this->close();
	
	m_hSocket = ::socket(AF_INET, SOCK_STREAM, 0);
	
	assert(m_hSocket != -1);
	if(m_hSocket == -1)
		return 1;

	return 0;
}

bool	TCPSocket::set_unblock()
{
	if (-1 == m_hSocket)
		return false;

	bool bBlock = false;
#if	(CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)

	u_long iMode = bBlock ? 0 : 1;
	return (SOCKET_ERROR != ioctlsocket(m_hSocket, FIONBIO, &iMode));

#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_LINUX)

	int32 flag;
	if (flag = fcntl(m_hSocket, F_GETFL, 0) < 0)
		return false;

	SET_DEL_BIT( flag, O_NONBLOCK, !bBlock );

	if (fcntl(m_hSocket, F_SETFL, flag) < 0)
		return false;

	return true;
#endif
}
bool	TCPSocket::connect(const char* host, short port, int timeval /* = 1000 */ )
{
	this->set_unblock();
	sockaddr_in	addrCon;
	memset(&addrCon, 0, sizeof(addrCon));
	addrCon.sin_family = AF_INET;
	addrCon.sin_port = htons(port);
	if (nullptr == host)
	{
#if	(CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
		addrCon.sin_addr.S_un.S_addr = htonl(INADDR_ANY);
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_LINUX)
		addrCon.sin_addr.s_addr = htonl(INADDR_ANY);
#endif
	}
	else
	{
#if	(CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
		addrCon.sin_addr.S_un.S_addr = inet_addr(host);
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_LINUX)
		addrCon.sin_addr.s_addr = inet_addr(host);
#endif
	}
	int nRet = ::connect(m_hSocket, (sockaddr*)&addrCon, sizeof(addrCon));

	if (nRet < 0) 
	{

#if	(CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
		int error = ::GetLastError();
		if ( WSAEWOULDBLOCK == error)
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_LINUX)
		int error = errno;
		if (EINPROGRESS == error)
#endif
		{
			fd_set wset;
			FD_ZERO(&wset);
			FD_SET(m_hSocket, &wset);
#if	(CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
			int nWidth = 0;
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_LINUX)
			int32 nWidth = m_hSocket + 1;
#endif
			struct timeval	tmval;
			tmval.tv_sec = long(timeval/1000);
			tmval.tv_usec = timeval%1000*1000;

			if (::select(nWidth, NULL, &wset, NULL, &tmval) > 0 && FD_ISSET(m_hSocket, &wset))
			{
				int valopt;
				socklen_t nLen = sizeof(valopt);

				getsockopt(m_hSocket, SOL_SOCKET, SO_ERROR, (char*)(&valopt), &nLen);
				if (valopt) 
				{
					//fprintf(stderr, "Error in connection() %d - %s/n", valopt, strerror(valopt));
					//exit(0);
					return false;
				}
			}
			else
			{
				//fprintf(stderr, "Timeout or error() %d - %s/n", valopt, strerror(valopt));
				//exit(0);
				return false;
			}
		}
		else
		{
			//fprintf(stderr, "Error connecting %d - %s/n", errno, strerror(errno));
			//exit(0);
			return false;
		}
	}

	return true;
}

int		TCPSocket::recv_msg(void* buffer, int len)
{
	int nRecvSize = ::recv(m_hSocket, (char*)buffer, len, 0);

	return nRecvSize;

}
int		TCPSocket::send_msg(void* buffer, int len)
{
	int nSendSize = ::send(m_hSocket, (char*)buffer, len, 0);

	return nSendSize;
}
bool	TCPSocket::close()
{
	if (-1 == m_hSocket) 
		return true;

	bool bRet = false;
#if	(CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	bRet = (0 == ::closesocket(m_hSocket));
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_LINUX)
	bRet = (0 == ::close(m_hSocket));
#endif

	m_hSocket = -1;

	return bRet;
}
void	TCPSocket::get_status(bool *pReadReady /* = nullptr */, bool* pWriteReady /* = nullptr */, bool* pExceptReady /* = nullptr */, int timeval /* = 1000 */)
{
	if( pReadReady )
		*pReadReady = false;

	if( pWriteReady )
		*pWriteReady = false;

	if( pExceptReady )
		*pExceptReady = false;

	if(-1 == m_hSocket)
		return;

	fd_set setRead, setWrite, setExcept;
	FD_ZERO(&setRead); FD_ZERO(&setWrite); FD_ZERO(&setExcept);
	FD_SET(m_hSocket, &setRead); FD_SET(m_hSocket, &setWrite); FD_SET(m_hSocket, &setExcept);

#if	(CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	int selectWith = 0;
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_LINUX)
	int selectWith = m_hSocket + 1;
#endif
	struct timeval	tmval;
	tmval.tv_sec = long(timeval/1000);
	tmval.tv_usec = timeval%1000*1000;

	int nRet = ::select(selectWith, 
		pReadReady	 ? &setRead  : nullptr,
		pWriteReady	 ? &setWrite : nullptr,
		pExceptReady ? &setExcept: nullptr, &tmval);

	if (nRet > 0)
	{
		if (FD_ISSET(m_hSocket, &setRead) && pReadReady != nullptr)	
			*pReadReady = true;
		if (FD_ISSET(m_hSocket, &setWrite) && pWriteReady != nullptr) 
			*pWriteReady = true;
		if (FD_ISSET(m_hSocket, &setExcept) && pExceptReady != nullptr)
			*pExceptReady = true;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///
CCNetwork::CCNetwork() 
	:m_port(0),
	m_bConnected(false)
{
	strcpy(m_szHost, "");
	this->scheduleUpdate();
}

CCNetwork::~CCNetwork()
{
	
}

bool CCNetwork::init()
{
	if( ! Node::init() )
		return false;

	m_socket.init();

	return true;
}

void CCNetwork::update(float delta)
{
	Node::update(delta);
	//////////////////////////////////////////////////////////////////////////
	// 增加 自定义 update 操作
}

int	CCNetwork::connect(const char* host, short port, int timeval /*= 1000*/)
{
	strcpy(m_szHost, host);
	port = port;
	
	if( !m_socket.connect(host, port, timeval) )
		return -1;

	m_bConnected = true;
	return 0;
}