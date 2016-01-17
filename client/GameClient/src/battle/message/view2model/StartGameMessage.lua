local StartGameMessage = class("StartGameMessage", battle.message.BattleBaseMessage)

StartGameMessage.model = nil


function StartGameMessage:ctor()
	self.super.ctor(self, battle.message.MessageType.view2model.StartGame)
end


return StartGameMessage