-------------------------------------------------------------------------------
-- @file Queue.lua
--
--
-- 队列的lua实现，先进先出
-------------------------------------------------------------------------------

local Queue = class("Queue")

---@field array_table#value   _container
Queue._container = nil
---@field #number _size
Queue._size = nil

function Queue:ctor()
	self:clear()
end

function Queue:push( data )
	table.insert(self._container, data)
	self._size = self._size + 1
end

function Queue:pop()
	if self._size <= 0 then return end

	local data =  table.remove(self._container, 1)
	self._size = self._size - 1
	return data
end

function Queue:clear()
	self._container = {}
	self._size = 0
end

return Queue