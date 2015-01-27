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

void*	PacketBuffer::getBuffer()
{
	return &m_data[m_read];
}

void*	PacketBuffer::getFreeBuffer()
{
	return &m_data[m_write];
}

int		PacketBuffer::getFreeSize()
{
	return (PACKET_MAX_SIZE - m_write);
}

int PacketBuffer::getDataSize()
{
	return m_dataSize;
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

void	PacketBuffer::ReadData(int size, void* buffer /*= nullptr*/)
{
	if (buffer != nullptr)
	{
		memcpy(buffer, &m_data[m_read], size);
	}
	m_read		+= size;
	m_dataSize	-= size;
}