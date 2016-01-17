local BattleScheduler = class("BattleScheduler")

---@field  array_table#SchedulerEntity  _schedulerEntitys
BattleScheduler._schedulerEntitys = nil
---@field #number
BattleScheduler._tagCount = nil

function BattleScheduler:ctor()
	self._schedulerEntitys = {}
	self._tagCount = 0
end

---@function getNextTag
---@return #number
function BattleScheduler:getNextTag()
	self._tagCount = self._tageCount + 1
	return self._tagCount
end

---@function registerScheduler
---@param boolean#boolean 	pause
---@param number#number   	rate
---@param function#function callback
---@param Object#Object  	owner
---@return #SchedulerEntity
function BattleScheduler:registerScheduler( pause, rate, callback, owner )
	local tag = self:getNextTag()
	local entity = battle.SchedulerEntity.new(tag, pause, rate, callback, owner )

	table.insert(self._schedulerEntitys, entity)
	return entity
end

function BattleScheduler:update()
	for idx, entity in ipairs(self._schedulerEntitys) do
		entity:run()
	end
end


return BattleScheduler