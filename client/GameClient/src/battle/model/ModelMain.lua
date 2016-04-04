require("battle.battle")
require("battle.model.model")
local ModelMain = class("ModelMain")

local s_instance = nil

---@filed BaseStack#BaseStack _stack
ModelMain._stack = nil
---@field BattleEngine#ModelMain _engine 
ModelMain._engine = nil
---@field   #boolean BattleEngine
ModelMain._isStop = false
local function _init( self )
end

function ModelMain:getInstance()
	if s_instance == nil then
		s_instance = ModelMain.new()
		_init(s_instance)
	end

	return s_instance
end

---@function reset
---@param BaseStack#BaseStack stack
function ModelMain:reset( stack )
	self._stack = stack
	self._isStop = false
	self._engine = battle.engine.BattleEngine.new()
end

function ModelMain:handleEndGame( sender , msg )
	self._isStop = true
end


function ModelMain:run()
	local stackManager = battle.stack.ModelStackManager.new(self._stack)
	
	self._engine:setStackManager(stackManager)
	self._engine:addSystem(battle.model.system.BattleEnterSystem.new())

	self._engine:add_listener(battle.message.MessageType.view2model.EndGame, self.handleEndGame, self)
	while not self._isStop do
		while not self._isStop and not self._stack:isPause() do
			stackManager:startFrame()
			while true do
				local msg = stackManager:popMessage()
				if msg == nil then
					break
				end

				battle.message.BattleBaseMessage.printSelf(msg, "ModelMain")

				self._engine:dispatch_event(msg.type, msg)
			end
			self._engine:update()
			stackManager:endFrame()

			if self._isStop then
				break
			end
			self._stack:pause(true)
		end
	end
	stackManager:pushMessage(battle.message.BattleBaseMessage.new(battle.message.MessageType.model2view.EndGame))
	stackManager:endFrame()
	print("model Main  end.................")
end

return ModelMain