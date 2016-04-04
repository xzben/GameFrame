local BattleEnterSystem = class("BattleEnterSystem", battle.engine.BattleSystem)

local _messageType = battle.message.MessageType

---@function ctor
function BattleEnterSystem:ctor( )
end

function BattleEnterSystem:handleBattleEnterMsg(sender, msg)
	print("BattleEnterSystem:handleBattleEnterMsg")
	local startMsg = battle.message.BattleBaseMessage.new(_messageType.model2view.StartGame)
	self:pushMessage(startMsg)
end

function BattleEnterSystem:start()
	self:add_listener(_messageType.view2model.StartGame, self.handleBattleEnterMsg, self)
end

return BattleEnterSystem