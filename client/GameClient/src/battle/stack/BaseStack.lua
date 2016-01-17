local BaseStack = class("BaseStack")

function BaseStack:ctor()

end

---@function _pushModelMessage
---@param array_table#BattleBaseMessage msg
function BaseStack:_pushModelMessages( msg )

end

---@function _popModelMessages
---@return array_table#BattleBaseMessage msg
function BaseStack:_popModelMessages()

end

---@function _pushViewMessages
---@param array_table#BattleBaseMessage msg
function BaseStack:_pushViewMessages( msg )

end

---@function _popViewMessages
---@return array_table#BattleBaseMessage msg
function BaseStack:_popViewMessages()

end

function BaseStack:reset()

end

---@function isPause
---@return boolean#boolean
function BaseStack:isPause()
	
end

function BaseStack:pause()

end

function BaseStack:resume()

end


return BaseStack