require("battle.battle")
require("battle.model.model")
local ModelMain = class("ModelMain", require("core.EventDispatcher"))
local _MessageType = battle.message.MessageType

local s_instance = nil

---@filed BaseStack#BaseStack _stack
ModelMain._stack = nil
---@filed boolean#boolean  _isStop
ModelMain._isStop = false

local function _init( self )
	self._isStop = false

	self:add_listener(_MessageType.view2model.EndGame, self.onEndGame, self)
	self:add_listener(_MessageType.model2view.EndGame, self.onEndGame, self)
end


function ModelMain:onEndGame(sender, msg)
	print("ModelMain:onEndGame")
	self._isStop = true
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
end

function ModelMain:run()
	local stackManager = battle.stack.ModelStackManager.new(self._stack)

	while not self._isStop do
		while not self._isStop and not self._stack:isPause() do
			stackManager:startFrame()
			while true do
				local msg = stackManager:popMessage()
				if msg == nil then
					print("----nil-------")
					break
				end

				battle.message.BattleBaseMessage.printSelf(msg)

				self:dispatch_event(msg.type, msg)
				print("---------dispath")
			end
			print("------------")
			stackManager:endFrame()

			if self._isStop then
				break
			end
			self._stack:pause()
		end
	end
	print("model Main  end.................")
end

return ModelMain