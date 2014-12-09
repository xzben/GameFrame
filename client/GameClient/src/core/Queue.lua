-------------------------------------------------------------------------------
-- @file Queue.lua
--
--
-- 队列的lua实现，先进先出
-------------------------------------------------------------------------------

Queue = Queue or class("Queue", EventDispatcher)

QueueEvent = {
	EVT_PUSH_DATA,
	EVT_POP_DATA,
	EVT_CLEAR_DATA,
}

function Queue:ctor()
	self._container = {}
end

function Queue:push( data )
	table.insert(self._container, data)
	self:dispatch_event(QueueEvent.EVT_PUSH_DATA, data)
end

function Queue:pop()
	local data =  table.remove(self._container, 1)
	self:dispatch_event(QueueEvent.EVT_POP_DATA, data)
	return data
end

function Queue:clear()
	self._container = {}
	self:dispatch_event(QueueEvent.EVT_CLEAR_DATA)
end