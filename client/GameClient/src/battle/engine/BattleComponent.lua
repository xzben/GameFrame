local BattleComponent = class("BattleComponent")

---@field  BattleEntity#BattleEntity _entity
BattleComponent._entity = nil

---@function ctor
---@param BattleEntity#BattleEntity  entity
function BattleComponent:ctor( entity )
	self._entity = entity
end

return BattleComponent