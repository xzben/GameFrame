#include "MemoryPool.h"
#include <cassert>

typedef unsigned int uint32;
typedef int			 int32;

//basic memory node structure
struct apr_memnode_t{
	uint32			magic;			//用于标记这个内存块是内存池申请的			    
	apr_memnode_t	*next;			//指向下一个内存空间节点
	apr_memnode_t	**ref;			//指向当前内存空间节点
	uint32			index;			//当前内存空间节点的总共内存大小
	uint32			free_index;		//当前内存空间中的可用空间
	char*			first_avail;	//指向当前可用空间的起始地址　　	　　　
	char*			endp;			//指向当前可用地址的结束地址　
};

/*
*	function:	计算最接近nSize 的 nBoundary 的整数倍的整数，获得按指定字节对齐后的大小
*	parameter:	__nSize 为整数， _nBoundary，必须为 2 的倍数
*	example:	Align(7， 4) = 8，Align(21, 16) = 32
*/
#define Align(__nSize, __nBoundary) (( (__nSize) + (__nBoundary)-1) & ~((__nBoundary) - 1))

class Allocator
{
public:

public:
	/*
	*	nMinIndex		用于计算最小内存块大小 最小内存单元块的大小 = Align(1<<nMinIndex, DEFAULT_ALIGN)
	*	nMaxSize		分配器list上最多挂靠的重复利用的内存大小
	*/
	Allocator(uint32_t nMinIndex, uint64_t nMaxSize = MemoryPool::APR_ALLOCATOR_MAX_FREE_UNLIMITED, uint32_t list_size = MemoryPool::DEFAULT_LIST_SIZE);
	virtual ~Allocator();
	inline const int GetMemNodeSize()
	{
		const int nMemNodeSize = Align(sizeof(apr_memnode_t), MemoryPool::DEFAULT_ALIGN);
		return nMemNodeSize;
	}
	/*
	*	获得当前分配器分配的内存块的标记值
	*/
	inline uint32 GetMagic()
	{
		return m_uiMagic;
	}
	/*
	*	获得 nAllocSize 空间大小的节点
	*/
	apr_memnode_t*  Alloc(size_t nAllocSize);
	/*
	*	释放node节点的空间，注意这里的释放不一定会直接给系统回收
	*	可能是暂时留在分配器中，给下次要用的内存使用
	*/
	void Free(apr_memnode_t *node);
private:
	/*
	*	生成一个较大的随机数字
	*/
	static inline uint32	CreateMagic()
	{
		double start = 1, end = RAND_MAX;
		double uiMagic = (start + (end - start)*rand()/(RAND_MAX+1.0));
		uiMagic *= uiMagic;
		return (uint32)uiMagic;
	}
	
	/*
	*	function:	设置分配子的最大内存分配空间限制，此设置关系到，
	*				当分配子中有多大内存时会将内存返回给系统回收
	*	paramter:	allocator : 要设置的分配子， nSize： 要设置的大小
	*	
	*/
	void inline SetMaxSize(size_t nSize)
	{
		uint32 uiMaxIndex = Align(nSize, BOUNDARY_SIZE) >> BOUNDARY_INDEX;
		
		m_uiMaxIndex = uiMaxIndex;
	}
	/*
	*	将分配器中挂载的空间全部给系统回收
	*/
	void Destroy();
private:
	uint32_t			m_uiMagic;				//用于记录次分配器分配的内存块的标记值
	uint32_t			m_uiCurMaxBlockIndex;	//分配器中当前可用的最大块的的大小index
	uint32_t			m_uiMaxIndex;			//分配器可以存储的最大空间大小	m_uiMaxIndex * BOUNDARY_SIZE
	uint32_t			m_uiCurAllocIndex;		//当前已经分配的可留在分配器中的空间大小  m_uiCurAllocIndex * BOUNDARY_SIZE
	Mutex				m_mutex;				//多线程访问锁
	apr_memnode_t		**m_pfree;	//分配器当前挂载的可用内存块
	const uint32_t		BOUNDARY_INDEX;			//最小的内存块的index
	const uint32_t		BOUNDARY_SIZE;			//内存池中的内存块的单元大小
	const uint32_t		MIN_ALLOC;				//内存池中最小分配的内存大小 = 2*BOUNDAY_SIZE
	const uint32_t		LIST_SIZE;				//内存池中挂靠复用内存的list的大小,其大小决定内存池中可挂靠多少种不同大小的内存块。

};

/////////////////////////////////////////////////////////////////////////////////////////
//class Allocator public
Allocator::Allocator(uint32_t nMinIndex, uint64_t nMaxSize /* = APR_ALLOCATOR_MAX_FREE_UNLIMITED */, uint32_t list_size /*= DEFAULT_LIST_SIZE*/)
	:BOUNDARY_INDEX(nMinIndex),
	BOUNDARY_SIZE( Align(1<<BOUNDARY_INDEX, MemoryPool::DEFAULT_ALIGN) ),
	MIN_ALLOC(2*BOUNDARY_SIZE),
	LIST_SIZE(list_size)
{
	m_uiMagic = CreateMagic();
	m_uiCurMaxBlockIndex = 0; //初始状态下，m_pfree[] 为空，所以没有最大可用块 
	m_uiMaxIndex = MemoryPool::APR_ALLOCATOR_MAX_FREE_UNLIMITED;//初始状态为可存储空间无限
	m_uiCurAllocIndex = 0;//当前已经分配的可留在分配器中的空间大小，其值总是在 m_uiMaxIndex范围内
	m_pfree = new apr_memnode_t*[LIST_SIZE];

	memset(m_pfree, 0, sizeof(apr_memnode_t*)*LIST_SIZE);

	if(nMaxSize != MemoryPool::APR_ALLOCATOR_MAX_FREE_UNLIMITED)
		SetMaxSize(nMaxSize);
}

Allocator::~Allocator()
{
	Destroy();
}
apr_memnode_t* Allocator::Alloc(size_t nAllocSize)
{
	apr_memnode_t *node, **ref;
	uint32 uiCurMaxBlockIndex;
	size_t nSize, i, index;

	const int nMemNodeSize = GetMemNodeSize();

	nSize = Align(nAllocSize + nMemNodeSize, BOUNDARY_SIZE);
	if(nSize < nAllocSize) //可能由于nAllocSize过大导致计算的nSize比nAllocSize小
	{
		return NULL;
	}
	if(nSize < MIN_ALLOC)
		nSize = MIN_ALLOC;

	//由于最小的size = MIN_ALLOC = 2*BOUNDARY_SIZE 所以index 最小都会为 1
	index = (nSize >> BOUNDARY_INDEX) - 1;
	if(index > UINT32_MAX) //申请的空间过大则不分配
	{
		return NULL;
	}

	Guard guard(&m_mutex);
	//当前存在大小够用的内存块
	if(index <= m_uiCurMaxBlockIndex)
	{
		uiCurMaxBlockIndex = m_uiCurMaxBlockIndex;
		ref = &m_pfree[index];
		i = index;
		while(NULL == *ref && i < uiCurMaxBlockIndex)
			ref++, i++;

		if(NULL != (node = *ref))
		{
			//如果找到的可用内存块是当前分配器中最大的块，且是最后一块最大块
			//则更新分配器中当前的可用最大块
			if(NULL == (*ref = node->next) && i >= uiCurMaxBlockIndex)
			{
				do{
					ref--;
					uiCurMaxBlockIndex--;
				}while(NULL == *ref && uiCurMaxBlockIndex > 0);
				m_uiCurMaxBlockIndex = uiCurMaxBlockIndex;
			}

			m_uiCurAllocIndex -= (node->index + 1);
			if(m_uiCurAllocIndex < 0) m_uiCurAllocIndex = 0;

			node->next = NULL;
			node->first_avail= (char*)node + nMemNodeSize;
			return node;
		}
	}
	else if(m_pfree[0])//如果有可用的大内存块在可用的大内存块中寻找
	{
		ref = &m_pfree[0];
		while(NULL != (node = *ref) && index > node->index)
			ref = &node->next;

		if(node)
		{
			*ref = node->next;
			m_uiCurAllocIndex -= (node->index + 1);
			if(m_uiCurAllocIndex < 0) m_uiCurAllocIndex = 0;
			
			node->next = NULL;
			node->first_avail = (char*)node + nMemNodeSize;
			return node;
		}
	}

	//如果分配新内存失败
	if(NULL == (node = (apr_memnode_t*)malloc(nSize)))
	{
		return NULL;
	}

	node->magic = m_uiMagic;
	node->next = NULL;
	node->index = index;
	node->first_avail = (char*)node + nMemNodeSize;
	node->endp = (char*)node + nSize;

	return node;
}
void Allocator::Free(apr_memnode_t *node)
{
	apr_memnode_t *next, *freelist = NULL;
	uint32 index, uiCurMaxBlockIndex;
	uint32 uiMaxIndex, uiCurAllocIndex;

	m_mutex.lock();

	uiCurMaxBlockIndex = m_uiCurMaxBlockIndex;
	uiMaxIndex = m_uiMaxIndex;
	uiCurAllocIndex = m_uiCurAllocIndex;
	do{
		next = node->next;
		index = node->index;

		if(MemoryPool::APR_ALLOCATOR_MAX_FREE_UNLIMITED != uiMaxIndex
			&& uiCurAllocIndex >= uiMaxIndex) //如果当前 list 挂靠的内存块的size 超过了 最大限制则释放此节点
		{
			node->next = freelist;
			freelist = node;
		}
		else if(index < LIST_SIZE)
		{
			if(NULL == (node->next = m_pfree[index])
				&& index > uiCurMaxBlockIndex)
			{
				uiCurMaxBlockIndex = index;
			}
			m_pfree[index] = node;
			
			uiCurAllocIndex += (index + 1);
		}
		else
		{
			node->next = m_pfree[0];
			m_pfree[0] = node;

			uiCurAllocIndex += (index + 1);
		}
	}while(NULL != (node = next));
	m_uiCurMaxBlockIndex = uiCurMaxBlockIndex;
	m_uiCurAllocIndex = uiCurAllocIndex;
	m_mutex.unlock();

	while(NULL != freelist)
	{
		node = freelist;
		freelist = node->next;
		free(node);
	}
}

void Allocator::Destroy()
{
	uint32 index;
	apr_memnode_t *node, **ref;

	for(index = 0; index < LIST_SIZE; index++)
	{
		ref = &m_pfree[index];
		while((node = *ref) != NULL){
			*ref = node->next;
			free(node);
		}
	}
	delete[] m_pfree;
}
/////////////////////////////////////////////////////////////////////////////////////////
//class MemoryPool public
MemoryPool::MemoryPool(uint32_t nMinIndex, uint64_t nMaxSize /*= MemoryPool::APR_ALLOCATOR_MAX_FREE_UNLIMITED*/, uint32_t list_size /*= MemoryPool::DEFAULT_LIST_SIZE*/)
{
	m_pAllocator = new Allocator(nMinIndex, nMaxSize, list_size);
}

void* MemoryPool::Alloc(uint64_t nAllocaSize)
{
	apr_memnode_t* node = m_pAllocator->Alloc(nAllocaSize);
	if(node == NULL)
	{
		return NULL;
	}
	return node->first_avail;
}
bool MemoryPool::Free(void* pMem)
{
	if(NULL == pMem)
	{
		return false;
	}
	apr_memnode_t* node = (apr_memnode_t*)((char*)pMem - m_pAllocator->GetMemNodeSize());
	if(node->magic != m_pAllocator->GetMagic()) //如果此段内存不是此内存池的分配器分配的
	{
		assert(false);
		return false;
	}
	m_pAllocator->Free(node);
	return true;
}
MemoryPool::~MemoryPool()
{
	if(m_pAllocator)
		delete m_pAllocator;
}