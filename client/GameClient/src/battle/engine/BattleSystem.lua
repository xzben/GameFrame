local BattleSystem = class("BattleSystem")

---@filed BattleEngine#BattleEngine _engine
BattleSystem._engine = nil
---@field SchedulerEntity#SchedulerEntity _schedulerEntity
BattleSystem._schedulerEntity = nil

---@function ctor
---@param BattleEngine#BattleSystem engine
function BattleSystem:ctor( engine )
	self._engine = engine
end

function BattleSystem:start()

end

function BattleSystem:registerScheduler( pause, rate )
	self._schedulerEntity = self._engine:registerScheduler( pause, rate, self.update, self )
end

function BattleSystem:pauseScheduler()
	if self._schedulerEntity then
		self._schedulerEntity:pause()
	end
end

function BattleSystem:resumeScheduler()
	if self._schedulerEntity then
		self._schedulerEntity:resume()
	end
end

function BattleSystem:update()

end

return BattleSystem