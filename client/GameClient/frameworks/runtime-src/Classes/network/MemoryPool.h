#ifndef __2014_12_19_MEMORY_POOL_H__
#define __2014_12_19_MEMORY_POOL_H__

#include <stdint.h>
#include "Mutex.h"

enum MemSize
{
	SIZE1K = 1024,
	SIZE1M = 1024 * SIZE1K,
	SIZE1G = 1024 * SIZE1M,
};

class Allocator;

class MemoryPool
{
public:
	MemoryPool(size_t nMaxSize = 0);
	virtual ~MemoryPool();
	virtual void* Alloc(size_t nAllocaSize);
	virtual bool Free(void* pMem);
private:
	Allocator	*m_pAllocator;
	Mutex		m_mutex;
};

#endif//__2014_12_19_MEMORY_POOL_H__