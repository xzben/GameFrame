local ModelStackManager = class("ModelStackManager", battle.stack.BaseStackManager)

local endFrameMsg = battle.message.BattleBaseMessage.new(battle.message.MessageType.model2view.EndFrame)

function ModelStackManager:startFrame()
	self._curFrame = self._curFrame + 1
	
	if #self._inputMessages <= 0 then
		self._inputMessages = self:_popMessageFromStack()
	end 

end

function ModelStackManager:endFrame()
	self:pushMessage(endFrameMsg)
	self:_pushMessageToStack(self._outputMessages)
	self._outputMessages = {}
end

---@function _popMessageFromStack
---@return array_table#BattleBaseMessage
function ModelStackManager:_popMessageFromStack()
	return self._stack:_popModelMessages()
end

---@function _pushMessageToStack
---@param array_table#BattleBaseMessage  msgs
function ModelStackManager:_pushMessageToStack( msgs )
	self._stack:_pushViewMessages(msgs)
end

return ModelStackManager