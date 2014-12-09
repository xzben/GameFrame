-------------------------------------------------------------------------------
-- @file Stack.lua
--
--
-- 堆栈的lua实现，后进先出
-------------------------------------------------------------------------------

Stack = Stack or class("Stack", EventDispatcher)
StackEvent = {
	EVT_PUSH_DATA,
	EVT_POP_DATA,
	EVT_CLEAR_DATA,
}

function Stack:ctor()
	self._container = {}
end

function Stack:push( data )
	table.insert(self._container, data)
	self:dispatch_event(StackEvent.EVT_PUSH_DATA, data)
end

function Stack:pop()
	local data =  table.remove(self._container)
	self:dispatch_event(StackEvent.EVT_POP_DATA, data)
	return data
end

function Stack:clear()
	self._container = {}
	self:dispatch_event(StackEvent.EVT_CLEAR_DATA)
end