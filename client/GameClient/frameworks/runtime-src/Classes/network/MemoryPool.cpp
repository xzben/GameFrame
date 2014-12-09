#include "MemoryPool.h"

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

class Allocator
{
public:
	enum{
		APR_ALLOCATOR_MAX_FREE_UNLIMITED = 0,	//代表分配器分配的内存没有上限
		DEFAULT_ALIGN = 8,						//代表 8 字节对齐
		MAX_INDEX = 20,							//代表内存列表的节点	
		BOUNDARY_INDEX = 12,					// 内存块的对齐 index 
		BOUNDARY_SIZE =  (1 << BOUNDARY_INDEX), // 内存块的对齐大小size
		MIN_ALLOC = 2*BOUNDARY_SIZE,
	};
public:
	Allocator(size_t nMaxSize = APR_ALLOCATOR_MAX_FREE_UNLIMITED);
	virtual ~Allocator();
	inline const int GetMemNodeSize()
	{
		const int nMemNodeSize = Align(sizeof(apr_memnode_t), DEFAULT_ALIGN);
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
	*	function:	计算最接近nSize 的 nBoundary 的整数倍的整数，获得按指定字节对齐后的大小
	*	parameter:	nSize 为整数， nBoundary，必须为 2 的倍数
	*	example:	Align(7， 4) = 8，Align(21, 16) = 32
	*/
	static inline size_t Align(size_t nSize, size_t nBoundary)
	{
		return ((nSize +nBoundary-1) & ~(nBoundary - 1));
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
		
		//设置新的最大可存放空间大小，这操作要保证当前 m_uiCurAllocIndex(当前可存储在分配器中的内存大小)
		//做合理的调整，如果设置新最大值时，m_uiCurAllocIndex ==  m_uiMaxIndex 则要做相应的增加，
		//如果 m_uiCurAllocIndex < m_uiMaxIndex 那么加上这个差值也不会影响，因为 m_uiCurAllocIndex 会在后续的使用中
		//达到这个值。
		m_uiCurAllocIndex += uiMaxIndex - m_uiMaxIndex;
		m_uiMaxIndex = uiMaxIndex;

		if(m_uiCurAllocIndex > uiMaxIndex)
			m_uiCurAllocIndex = uiMaxIndex;
	}
	/*
	*	将分配器中挂载的空间全部给系统回收
	*/
	void Destroy();
private:
	uint32			m_uiMagic; //用于记录次分配器分配的内存块的标记值
	uint32			m_uiCurMaxBlockIndex; //分配器中当前可用的最大块的的大小index
	uint32			m_uiMaxIndex;//分配器可以存储的最大空间大小index
	uint32			m_uiCurAllocIndex;//当前已经分配的可留在分配器中的空间大小，其值总是在 m_uiMaxIndex范围内
	Mutex			m_mutex;		 //多线程访问锁
	apr_memnode_t	*m_pfree[MAX_INDEX];//分配器当前挂载的可用内存块
};

/////////////////////////////////////////////////////////////////////////////////////////
//class Allocator public
Allocator::Allocator(size_t nMaxSize /*= APR_ALLOCATOR_MAX_FREE_UNLIMITED*/)
{
	m_uiMagic = CreateMagic();
	m_uiCurMaxBlockIndex = 0; //初始状态下，m_pfree[] 为空，所以没有最大可用块 
	m_uiMaxIndex = APR_ALLOCATOR_MAX_FREE_UNLIMITED;//初始状态为可存储空间无限
	m_uiCurAllocIndex = 0;//当前已经分配的可留在分配器中的空间大小，其值总是在 m_uiMaxIndex范围内
	memset(m_pfree, 0, sizeof(m_pfree));

	if(nMaxSize != APR_ALLOCATOR_MAX_FREE_UNLIMITED)
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
	if(index <= m_uiCurMaxBlockIndex)//当前存在可用的内存块够index
	{
		m_mutex.lock();

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

			m_uiCurAllocIndex += node->index + 1;
			if(m_uiCurAllocIndex > m_uiMaxIndex)
				m_uiCurAllocIndex = m_uiMaxIndex;

			m_mutex.unlock();
			node->next = NULL;
			node->first_avail= (char*)node + nMemNodeSize;
			return node;
		}
		m_mutex.unlock();
	}
	else if(m_pfree[0])//如果有可用的大内存块在可用的大内存块中寻找
	{
		m_mutex.lock();
		ref = &m_pfree[0];
		while(NULL != (node = *ref) && index > node->index)
			ref = &node->next;

		if(node)
		{
			*ref = node->next;
			m_uiCurAllocIndex += node->index + 1;
			if(m_uiCurAllocIndex > m_uiMaxIndex)
				m_uiCurAllocIndex = m_uiMaxIndex;

			m_mutex.unlock();
			node->next = NULL;
			node->first_avail = (char*)node + nMemNodeSize;
			return node;
		}
		m_mutex.unlock();
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

		if(APR_ALLOCATOR_MAX_FREE_UNLIMITED != uiMaxIndex
			&& index + 1 > uiCurAllocIndex) //如果当前index + 1 空间是超出限定maxindex 的空间则将其删除
		{
			node->next = freelist;
			freelist = node;
		}
		else if(index < MAX_INDEX)
		{
			if(NULL == (node->next = m_pfree[index])
				&& index > uiCurMaxBlockIndex)
			{
				uiCurMaxBlockIndex = index;
			}
			m_pfree[index] = node;
			if(uiCurAllocIndex >= index + 1)
				uiCurAllocIndex -= index + 1;
			else
				uiCurAllocIndex = 0;
		}
		else
		{
			node->next = m_pfree[0];
			m_pfree[0] = node;
			if(uiCurAllocIndex >= index + 1)
				uiCurAllocIndex -= index + 1;
			else
				uiCurAllocIndex = 0;

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

	for(index = 0; index < MAX_INDEX; index++)
	{
		ref = &m_pfree[index];
		while((node = *ref) != NULL){
			*ref = node->next;
			free(node);
		}
	}
}
/////////////////////////////////////////////////////////////////////////////////////////
//class MemoryPool public
MemoryPool::MemoryPool(size_t nMaxSize /*= Allocator::APR_ALLOCATOR_MAX_FREE_UNLIMITED*/)
{
	m_pAllocator = new Allocator(nMaxSize);
}
void* MemoryPool::Alloc(size_t nAllocaSize)
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