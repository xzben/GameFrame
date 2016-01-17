local BaseStackManager = class("BaseStackManager")

---@field BaseStack#BaseStack _stack
BaseStackManager._stack = nil
---@field number#number   _curFrame 
BaseStackManager._curFrame = nil
---@field array_table#BattleBaseMessage _inputMessages
BaseStackManager._inputMessages = nil
---@field array_table#BattleBaseMessage _outputMessages
BaseStackManager._outputMessages = nil

function BaseStackManager:ctor( stack )
	print("BaseStackManager:ctor")
	self._stack = stack
	self._curFrame = 0
	self._inputMessages = {}
	self._outputMessages = {}
end

function BaseStackManager:startFrame()
	error("please overwrite this")
end

function BaseStackManager:endFrame()
	error("please overwrite this")
end

---@function _popMessageFromStack
---@return array_table#BattleBaseMessage
function BaseStackManager:_popMessageFromStack()
	error("please overwrite this")
end

---@function _popMessageFromStack
---@param array_table#BattleBaseMessage  msgs
function BaseStackManager:_pushMessageToStack( msgs )
	error("please overwrite this")
end

---@function pushMessage
---@param BattleBaseMessage#BattleBaseMessage msg
function BaseStackManager:pushMessage( msg )
	if msg == nil then
		error("push a nil msg")
		return
	end
	msg.class = nil
	msg.frame = self._curFrame
	
	table.insert(self._outputMessages, msg)
end

---@function popMessage
---@return BattleBaseMessage#BattleBaseMessage msg
function BaseStackManager:popMessage()
	if self._inputMessages[1] == nil then return nil end

	local msg = self._inputMessages[1]
	if msg.frame > self._curFrame then
		print("msg.frame:", msg.frame, "curFrame:",self._curFrame)
		return nil
	end

	return table.remove(self._inputMessages, 1)
end

function BaseStackManager:flush()
	self:_pushMessageToStack(self._outputMessages)
	self._outputMessages = {}
end

return BaseStackManager