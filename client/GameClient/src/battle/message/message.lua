module("battle.message", package.seeall)


battle.message.MessageType = require("battle.message.MessageType")

battle.message.BattleBaseMessage = require("battle.message.BattleBaseMessage")

require("battle.message.view2model.view2model")

require("battle.message.model2view.model2view")
return nil