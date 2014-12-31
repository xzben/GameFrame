/*******************************************************************
**		
** author : xzben 2014/12/09
** 存储客户端接收到的数据包
*******************************************************************/

#ifndef __2014_12_09_PACKET_H__
#define __2014_12_09_PACKET_H__

#include <queue>
#include "Mutex.h"

#define USE_MEMORY_POOL 1
#define PACKET_MAX_SIZE 4096

class PacketBuffer
{
public:
	PacketBuffer();
	~PacketBuffer();

	void*	getFreeBuffer();
	int		getFreeSize();
	void	FillData(int size, void* data = nullptr);
#if USE_MEMORY_POOL > 0
	void*	operator new(size_t size);
	void*	operator new[](size_t size);
	void	operator delete(void *pobj);
	void	operator delete[](void *pobj);
#endif

private:
	int		m_dataSize;					//当前有效数据大小
	char	m_data[PACKET_MAX_SIZE];	//数据buffer
	int		m_read;						//数据读取index
	int		m_write;					//数据写入index
};

class PacketQueue
{
public:
	PacketQueue();
	~PacketQueue();
	
	int					push(PacketBuffer* buf);

	PacketBuffer*		front();
	void				pop();
	bool				empty();
	void				clear();

private:
	std::queue<PacketBuffer*>	m_queue;
	Mutex						m_lock;
};
#endif//__2014_12_09_PACKET_H__