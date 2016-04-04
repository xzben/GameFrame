/********************************************************************************
*	文件名称:	condition.h														*
*	创建时间：	2014/06/24														*
*	作   者 :	xzben															*
*	文件功能:	系统中使用的线程同步条件变量										*
*********************************************************************************/

#ifndef __2014_10_12_CONDITION_H__
#define __2014_10_12_CONDITION_H__

#include <condition_variable>
#include <mutex>

/*
*
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

#endif // !__2014_10_12_CONDITION_H__