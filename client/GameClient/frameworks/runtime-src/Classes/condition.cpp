#include "conditon.h"

Condition::Condition()
{
	std::unique_lock<std::mutex> lock(m_mutex);
	m_NotifyCount = 0;
	m_WaitCount = 0;
}

Condition::~Condition()
{

}

void Condition::notify_one()
{
	std::unique_lock<std::mutex> lock(m_mutex);
	if (m_WaitCount > 0)
		m_NotifyCount += 1;
	m_condition.notify_one();
}

void Condition::notify_all()
{
	std::unique_lock<std::mutex> lock(m_mutex);
	m_NotifyCount = m_WaitCount;
	m_condition.notify_all();
}

void Condition::wait()
{
	std::unique_lock<std::mutex> lock(m_mutex);
	m_WaitCount += 1;
	while (m_NotifyCount <= 0)
		m_condition.wait(lock);
	m_WaitCount -= 1;
	m_NotifyCount -= 1;
}
