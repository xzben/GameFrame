local BattleEngine = class("BattleEngine")

---@field   map_table#array_table(BattleEntity)  _entitys  _entitys[EntityType] = { BattleEntity }
BattleEngine._entitys = nil
---@filed   array_table#BattleSystem  _systems
BattleEngine._systems = nil
---@field   BattleScheduler#BattleScheduler _scheduler
BattleEngine._scheduler = nil

function BattleEngine:ctor()
	self._entitys = {}
	self._systems = {}
	self._scheduler = battle.BattleScheduler.new()
end

function BattleEngine:update()
	self._scheduler:update()
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




return BattleEngine