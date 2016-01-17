local BattleEntity = class("BattleEntity")


---@filed BattleEngine#BattleEngine _engine
BattleEntity._engine = nil
---@field  array_table#BattleComponent  _components
BattleEntity._components = nil


function BattleEntity:ctor()
	self._components = {}
end

---@function setEngine
---@param BattleEngine#BattleEngine engine
function BattleEntity:setEngine( engine )
	self._engine = engine
end

return BattleEntity