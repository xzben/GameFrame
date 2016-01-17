local ViewManager = class("ViewManager", core.EventDispatcher)
local _MessageType = battle.message.MessageType

---@field
ViewManager._model = nil

---@function _init
---@param ViewManager#ViewManager self
local function _init( self )
	self:add_listener(_MessageType.model2view.StartGame, self.runBattleScene, self)
end

local s_instance = nil

---@function getInstance
---@return ViewManager#ViewManager
function ViewManager:getInstance()
	if s_instance == nil then
		s_instance = ViewManager.new()
		_init(s_instance)
	end

	return s_instance
end


function ViewManager:startLoading( model )
	game:session():replaceScene( cc.Scene:create() )
end

function ViewManager:runBattleScene( sender, msg )
	game:session():replaceScene( cc.Scene:create() )
end

function ViewManager:run( stack, model )
	self._model = model
	local stackManager = battle.stack.ViewStackManager.new(stack)

	local startMessage = battle.message.view2model.StartGameMessage.new()
	startMessage.model = model
	stackManager:pushMessage(startMessage)
	stackManager:endFrame()

	local frameInterval = cc.Director:getInstance():getAnimationInterval()
	cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()

		stackManager:startFrame()
		while true do
			local msg = stackManager:popMessage()

			if msg == nil then
				break
			end
			
			battle.message.BattleBaseMessage.printSelf(msg)

			if battle.message.BattleBaseMessage.isModelEndFrame( msg ) then
				stackManager:endFrame()
			end
			
			self:dispatch_event(msg.type, msg)
		end

	end, frameInterval, false)
end



return ViewManager