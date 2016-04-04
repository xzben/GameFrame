local BattleEngine = class("BattleEngine")

---@field   map_table#array_table(BattleEntity)  _entitys  _entitys[EntityType] = { BattleEntity }
BattleEngine._entitys = nil
---@filed   array_table#BattleSystem  _systems
BattleEngine._systems = nil
---@field   BattleScheduler#BattleScheduler _scheduler
BattleEngine._scheduler = nil
---@field   EventDispather#EventDispather _dispather
BattleEngine._dispather = nil
---@field   BaseStackManager#BaseStackManager _stackManager
BattleEngine._stackManager = nil

function BattleEngine:ctor()
	self._entitys = {}
	self._systems = {}
	self._scheduler = battle.engine.BattleScheduler.new()
	self._dispather = battle.EventDispatcher.new()
end

function BattleEngine:setStackManager( stackManager )
	self._stackManager = stackManager
end

function BattleEngine:update()
	self._scheduler:update()
end

function BattleEngine:add_listener(type, listener, owner)
	self._dispather:add_listener(type, listener, owner)
end

function BattleEngine:dispatch_event(type, ... )
	self._dispather:dispatch_event(type, ...)
end

---@function registerScheduler
---@param boolean#boolean 	pause
---@param number#number   	rate
---@param function#function callback
---@param Object#Object  	owner
---@return #SchedulerEntity
function BattleEngine:registerScheduler( pause, rate, callback, owner )
	return self._scheduler:registerScheduler( pause, rate, callback, owner )
end

function BattleEngine:pause()

end

---@function addSystem
---@param BattleSystem#BattleSystem system
function BattleEngine:addSystem( system )
	table.insert(self._systems, system)
	system:setEngine(self)
	system:start()
end

---@function pushMessage
---@param BattleBaseMessage#BattleBaseMessage msg
function BattleEngine:pushMessage( msg )
	self._stackManager:pushMessage(msg)
end



return BattleEngine