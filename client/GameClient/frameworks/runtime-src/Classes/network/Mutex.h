#ifndef __2014_12_9_MUTEX_H__
#define __2014_12_9_MUTEX_H__

#include <mutex>
#include <condition_variable>

/*
*	��������
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
	int						 m_NotifyCount;  //Ϊ�˷�ֹαװ�Ļ���
	int						 m_WaitCount;
};

/*
*	��������ʹ�� C++11 �ṩ�Ķ�ʱ������ʵ��
*	����ʹ�õ��Ƕ�ʱ��
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
#endif//__2014_12_9_MUTEX_H__