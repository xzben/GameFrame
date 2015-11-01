-------------------------------------------------------------------------------
-- @file Stack.lua
--
--
-- 堆栈的lua实现，后进先出
-------------------------------------------------------------------------------

local Stack = class("Stack")

function Stack:ctor()
	self._size = 0
	self._container = {}
end

function Stack:push( data )
	table.insert(self._container, data)
	self._size = self._size + 1
end

function Stack:pop()
	local data =  table.remove(self._container)
	self._size = self._size - 1
	return data
end

function Stack:size()
	return self._size
end

function Stack:clear()
	self._container = {}
end

return Stack