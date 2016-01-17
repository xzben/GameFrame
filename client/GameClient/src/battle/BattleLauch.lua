local BattleLauch = class("BattleLauch")


local s_instance = nil

local s_useThreadStack = true
---@field  BaseStack#BaseStack _stack
BattleLauch._stack = nil

local function _init( self )

	require("battle.battle")
	require("battle.view.view")

	if s_useThreadStack then
		self._stack = battle.stack.ThreadStack.new()
	else
		self._stack = battle.stack.CoroutineStack.new()
	end
end

function BattleLauch:getInstance()
	if s_instance == nil then
		s_instance = BattleLauch.new()
		_init( s_instance )
	end

	return s_instance
end

---@function start
-- @param xxx#xxx  model
function BattleLauch:start( model )
	battle.view.ViewManager:getInstance():startLoading(model)
	self._stack:reset()
	battle.view.ViewManager:getInstance():run(self._stack, model)
end

return BattleLauch