module("battle", package.seeall)

battle.EventDispatcher = require("core.EventDispatcher")

require("battle.engine.engine")

battle.BattleLauch = require("battle.BattleLauch")

require("battle.message.message")
require("battle.stack.stack")

return nil
