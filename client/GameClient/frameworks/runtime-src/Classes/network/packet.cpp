#include "packet.h"

#if USE_MEMORY_POOL > 0

#include "MemoryPool.h"
MemoryPool packetMemoryPool(sizeof(PacketBuffer), 10*MemSize::SIZE1M);

void*	PacketBuffer::operator new(size_t size)
{
	return packetMemoryPool.Alloc(size);
}

void*	PacketBuffer::operator new[](size_t size)
{
	return packetMemoryPool.Alloc(size);
}

void	PacketBuffer::operator delete(void *pobj)
{
	packetMemoryPool.Free(pobj);
}

void	PacketBuffer::operator delete[](void *pobj)
{
	packetMemoryPool.Free(pobj);
}

#endif

PacketBuffer::PacketBuffer()
{
	m_dataSize = 0;
	memset(m_data, 0, PACKET_MAX_SIZE);
}

PacketBuffer::~PacketBuffer()
{
	
}

void*	PacketBuffer::getFreeBuffer()
{
	return &m_data[m_write];
}

int		PacketBuffer::getFreeSize()
{
	return (PACKET_MAX_SIZE - m_write);
}

void	PacketBuffer::FillData(int size, void* data /*= nullptr*/)
{
	if(data != nullptr)
	{
		memcpy(&m_data[m_write], data, size);
	}
	m_dataSize	+= size;
	m_write		+= size;
}
//////////////////////////////////////////////////////////////////////////
PacketQueue::PacketQueue()
{
	
}

PacketQueue::~PacketQueue()
{
	this->clear();	
}

int PacketQueue::push(PacketBuffer* buf)
{
	Guard guard(&m_lock);
	m_queue.push(buf);

	return 0;
}

PacketBuffer* PacketQueue::front()
{
	Guard guard(&m_lock);
	PacketBuffer* ret = nullptr;
	if( !m_queue.empty()) ret = m_queue.front();
	return ret;
}

void PacketQueue::pop()
{
	Guard guard(&m_lock);
	if( !m_queue.empty()) m_queue.pop();
}

bool PacketQueue::empty()
{
	Guard guard(&m_lock);
	return m_queue.empty();
}

void PacketQueue::clear()
{
	Guard guard(&m_lock);
	while(m_queue.empty())
	{
		PacketBuffer* tmp = m_queue.front();
		m_queue.pop();
		delete tmp;
	}
}