#ifndef __2014_12_9_MUTEX_H__
#define __2014_12_9_MUTEX_H__

#include <mutex>
#include <condition_variable>

/*
*	条件变量
*/
class Condition
{
public:
	Condition();
	virtual ~Condition();

	void notify_one();
	void notify_all();

	void wait();
private:
	std::condition_variable  m_condition;
	std::mutex				 m_mutex;
	int						 m_NotifyCount;  //为了防止伪装的唤醒
	int						 m_WaitCount;
};

/*
*	互斥锁，使用 C++11 提供的定时锁对象实现
*	本锁使用的是定时锁
*/
class  Mutex
{
public:
	Mutex();
	virtual ~Mutex();
	void lock();
	bool try_lock(unsigned int milliseconds = 200);
	void unlock();
protected:
	std::timed_mutex	m_lock;
};

class Guard
{
public:
	Guard(Mutex* pMutex)
	{
		m_pGuardMuext = pMutex;
		if (nullptr != m_pGuardMuext)
		{
			m_pGuardMuext->lock();
		}
	}
	~Guard()
	{
		if (nullptr != m_pGuardMuext)
		{
			m_pGuardMuext->unlock();
		}
	}
private:
	Mutex	*m_pGuardMuext;
};
#endif//__2014_12_9_MUTEX_H__