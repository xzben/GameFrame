-------------------------------------------------------------------------------
-- @file BaseRole.lua 
--
--
-- 角色
--
-------------------------------------------------------------------------------
BaseRole = BaseRole or class("BaseRole", FiniteStateMachine)

function BaseRole.create()
	return BaseRole.extend(cc.Sprite:create, )
end

function BaseRole:ctor()

end

