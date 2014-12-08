-------------------------------------------------------------------------------
-- @file LauchScene.lua 
--
--
-- 游戏初始加载场景
--
-------------------------------------------------------------------------------

LauchScene = LauchScene or class("LauchScene", EventDispatcher)


function LauchScene.create()
	return LauchScene.extend(cc.Scene:create())
end

function LauchScene:ctor()

	
	local function handlercallback(event)
        if "enter" == event then
            self:on_enter()
        elseif "exit" == event then
            self:on_exit()
        end
    end
    self:registerScriptHandler(handlercallback)	
end

function LauchScene:on_enter( )
	self:init()
end

function LauchScene:on_exit( )
	--self:destroy()
end

function LauchScene:init()
	CocoStudioHelper.load_scene(self, "publish/FightScene.csb")
    self.main_ui_ = self:get_component_by_name("ui", "GUIComponent")
    self.hero_img_ = self:get_component_by_tag(10010, "CCSprite")
    self.hero_img_:setVisible(false)
end