local BattleSystem = class("BattleSystem")

---@filed BattleEngine#BattleEngine _engine
BattleSystem._engine = nil
---@field SchedulerEntity#SchedulerEntity _schedulerEntity
BattleSystem._schedulerEntity = nil

---@function ctor
function BattleSystem:ctor( engine )
	
end

---@function setEngine
---@param BattleEngine#BattleSystem engine
function BattleSystem:setEngine( engine )
	self._engine = engine
end

function BattleSystem:start()

end

---@function pushMessage
---@param BattleBaseMessage#BattleBaseMessage msg
function BattleSystem:pushMessage( msg )
	self._engine:pushMessage(msg)
end

function BattleSystem:add_listener(type, listener, owner)
	self._engine:add_listener(type, listener, owner)
end

function BattleSystem:dispatch_event(type, ...)
	self._engine:dispatch_event(type, ...)
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