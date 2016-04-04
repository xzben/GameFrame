module("battle.view", package.seeall)


battle.view.BattleLoadingScene = require("battle.view.scene.BattleLoadingScene")
battle.view.BaseBattleScene = require("battle.view.scene.BaseBattleScene")
battle.view.ViewManager = require("battle.view.ViewManager")


battle.view.sendMessage2Model = function ( msg  )
	battle.view.ViewManager:getInstance():sendMessage2Model(msg)
end

return nil