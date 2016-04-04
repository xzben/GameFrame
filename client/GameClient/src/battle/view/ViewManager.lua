local ViewManager = class("ViewManager", core.EventDispatcher)
local _MessageType = battle.message.MessageType

---@field
ViewManager._model = nil
---@field   BaseBattleScene#BaseBattleScene _battleScene 
ViewManager._battleScene = nil
---@field 	BattleEngine#BattleEngine _engine
ViewManager._engine = nil
---@field 	number#number _updateScheduler
ViewManager._updateScheduler = nil
---@function _init
---@param ViewManager#ViewManager self
local function _init( self )
	
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

function ViewManager:reset()
	self._engine = battle.engine.BattleEngine.new()
	self._engine:add_listener(battle.message.MessageType.model2view.StartGame, self.handleStartGame, self)
	self._engine:add_listener(battle.message.MessageType.model2view.EndGame, self.handleEndGame, self)
end

function ViewManager:startLoading( model )
	game.session():pushScene( battle.view.BattleLoadingScene.create( model ) )
end


local function _createBattleScene( model )
	return battle.view.BaseBattleScene.create(model)
end

function ViewManager:handleStartGame(sender, msg)
	self._battleScene = _createBattleScene(self._model )
	game.session():replaceScene( self._battleScene )
end

function ViewManager:handleEndGame(sender, msg)
	self:removeScheduler()
	game.session():popScene()
end

---@function pushMessage
---@param BattleBaseMessage msg
function ViewManager:sendMessage2Model( msg )
	self._engine:pushMessage(msg)
end

function ViewManager:removeScheduler()
	if self._updateScheduler then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._updateScheduler)
		self._updateScheduler = nil
	end
end
---@function run
---@param BaseStack#BaseStack stack
---@param xxx#xxx  model
function ViewManager:run( stack, model )
	self._model = model
	local stackManager = battle.stack.ViewStackManager.new(stack)
	self._engine:setStackManager(stackManager)

	local startMessage = battle.message.view2model.StartGameMessage.new()
	startMessage.model = model
	stackManager:pushMessage(startMessage)
	stackManager:endFrame()

	self:removeScheduler()
	local frameInterval = cc.Director:getInstance():getAnimationInterval()
	self._updateScheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
		stackManager:startFrame()
		while true do
			local msg = stackManager:popMessage()

			if msg == nil then
				break
			end

			--battle.message.BattleBaseMessage.printSelf(msg, "ViewManager")
			if battle.message.BattleBaseMessage.isModelEndFrame( msg ) then
				stackManager:endFrame()
			else
				battle.message.BattleBaseMessage.printSelf(msg, "ViewManager")
			end
			
			self._engine:dispatch_event(msg.type, msg)
		end

	end, frameInterval, false)
end



return ViewManager