local BaseBattleScene = class("BaseBattleScene")


---@field ViewStackManager#ViewStackManager _stackManager
BaseBattleScene._stackManager = nil

---@function ctor
---@param ViewStackManager#ViewStackManager stackManager
function BaseBattleScene:ctor( stackManager )
	self._stackManager = stackManager
end

function BaseBattleScene:start()

end


return BaseBattleScene