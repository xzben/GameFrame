local ThreadStack = class("ThreadStack", battle.stack.BaseStack)

---@field BattleStack#BattleStack _obj
ThreadStack._cobj = nil

function ThreadStack:ctor()
	print("ThreadStack:ctor()")
	self._cobj = BattleStack.getInstance()
end

---@function _pushModelMessage
---@param array_table#BattleBaseMessage msgs
function ThreadStack:_pushModelMessages( msgs )
	self._cobj:pushInputMessages(msgs)
end

---@function _popModelMessages
---@return array_table#BattleBaseMessage msg
function ThreadStack:_popModelMessages()
	return self._cobj:popInputMessages()
end

---@function _pushViewMessages
---@param array_table#BattleBaseMessage msg
function ThreadStack:_pushViewMessages( msgs )
	self._cobj:pushOutputMessages(msgs)
end

---@function _popViewMessages
---@return array_table#BattleBaseMessage msg
function ThreadStack:_popViewMessages()
	return self._cobj:popOutputMessages()
end

---@function reset   此函数是只能由view中的lauch调用的
function ThreadStack:reset()
	self._cobj:reset("battle/model/ThreadEntry.lua", "ThreadBattleInitCallback")
	self:pause()
	self._cobj:run("ThreadBattleRunCallback")
end

---@function pause
---@param boolean#boolean yeild 是否挂起线程，给ThreadStack用的
function ThreadStack:pause(yeild)
	self._cobj:pause(yeild)
end

function ThreadStack:resume()
	self._cobj:resume()
end

---@function isPause
---@return boolean#boolean
function ThreadStack:isPause()
	return self._cobj:isPause()
end

return ThreadStack