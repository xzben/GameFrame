-------------------------------------------------------------------------------
-- @file Queue.lua
--
--
-- 队列的lua实现，先进先出
-------------------------------------------------------------------------------

local Queue = class("Queue")

function Queue:ctor()
	self._container = {}
end

function Queue:push( data )
	table.insert(self._container, data)
end

function Queue:pop()
	local data =  table.remove(self._container, 1)
	return data
end

function Queue:clear()
	self._container = {}
end

return Queue