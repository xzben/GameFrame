local ViewStackManager = class("ViewStackManager", battle.stack.BaseStackManager)

function ViewStackManager:startFrame()
	if #self._inputMessages <= 0 then
		self._inputMessages = self:_popMessageFromStack()
	end 
end

function ViewStackManager:endFrame()
	self:_pushMessageToStack(self._outputMessages)
	self._outputMessages = {}
	self._curFrame = self._curFrame + 1
end

---@function _popMessageFromStack
---@return array_table#BattleBaseMessage
function ViewStackManager:_popMessageFromStack()
	self._stack:resume()
	return self._stack:_popViewMessages()
end

---@function _pushMessageToStack
---@param array_table#BattleBaseMessage  msgs
function ViewStackManager:_pushMessageToStack( msgs )
	self._stack:_pushModelMessages(msgs)
end

return ViewStackManager