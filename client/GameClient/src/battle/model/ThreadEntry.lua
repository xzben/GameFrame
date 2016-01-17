require("trackback")
require("cocos.cocos2d.extern")
local ModelMain = require("battle.model.ModelMain")
local threadStack = require("battle.stack.ThreadStack").new()

function ThreadBattleInitCallback()
	local status, msg = xpcall(function()
		ModelMain:getInstance():reset(threadStack)
	end, __G__TRACKBACK__)

	if not status then
		error(msg)
	end
end

function ThreadBattleRunCallback()
	local status, msg = xpcall(function()
		ModelMain:getInstance():run()
	end, __G__TRACKBACK__)

	if not status then
		error(msg)
	end
end