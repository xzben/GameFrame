-------------------------------------------------------------------------------
-- @file PhysicsScene.lua 
--
--
-- 游戏主场景
--
-------------------------------------------------------------------------------

PhysicsScene = PhysicsScene or class("GameScene", EventDispatcher)

function PhysicsScene.create()
	return PhysicsScene.extend(cc.Scene:create())
end

function PhysicsScene:ctor()

	local function handlercallback(event)
        if "enter" == event then
            self:on_enter()
        elseif "exit" == event then
            self:on_exit()
        end
    end
    self:registerScriptHandler(handlercallback)	
end

function PhysicsScene:on_enter( )
	self:init()
end

function PhysicsScene:on_exit( )
	self:destroy()
end

function PhysicsScene:init()

end

