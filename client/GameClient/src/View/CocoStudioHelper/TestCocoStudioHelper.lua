-------------------------------------------------------------------------------
-- @file TestCocoStudioHelperScene.lua 
--
--
-- 游戏主场景
--
-------------------------------------------------------------------------------
local Testlayer = Testlayer or class("Testlayer", EventDispatcher)

function Testlayer.create()
    return Testlayer.extend(cc.Layer:create())
end

function Testlayer:ctor()

    self:setContentSize(480, 320)
    local function handlercallback(event)
        if "enter" == event then
            self:on_enter()
        elseif "exit" == event then
            self:on_exit()
        end
    end
    self:registerScriptHandler(handlercallback) 
end

function Testlayer:on_enter( )
    self:init()
end

function Testlayer:on_exit( )
    self:destroy()
end

function Testlayer:control_init_btn_clsoe(control_obj)
    local function btnCallback(sender, eventType)
        if  eventType == ccui.TouchEventType.ended then
            self:removeFromParent()
        end
    end
    control_obj:addTouchEventListener(btnCallback)
end

function Testlayer:control_init_btn_login(control_obj)
    local function btnCallback(sender, eventType)
        if  eventType == ccui.TouchEventType.ended then
            
        end
    end
    control_obj:addTouchEventListener(btnCallback)
end

local TestlayerControlMap = {
    {tag_name = "close_Button", init_callback = Testlayer.control_init_btn_clsoe},
    {tag_name = "login_Button", init_callback = Testlayer.control_init_btn_login},
}

function Testlayer:init()
    CocoStudioHelper.load_ui(self, "cocoStudioHelper/DemoLogin.csb", TestlayerControlMap ) 
end
---------------------------------------------------------------------------------------------------------------
TestCocoStudioHelperScene = TestCocoStudioHelperScene or class("TestCocoStudioHelperScene", EventDispatcher)


function TestCocoStudioHelperScene.create()
	return TestCocoStudioHelperScene.extend(cc.Scene:create())
end

function TestCocoStudioHelperScene:ctor()

	
	local function handlercallback(event)
        if "enter" == event then
            self:on_enter()
        elseif "exit" == event then
            self:on_exit()
        end
    end
    self:registerScriptHandler(handlercallback)	
end

function TestCocoStudioHelperScene:on_enter( )
	self:init()
end

function TestCocoStudioHelperScene:on_exit( )
	self:destroy()
end

function TestCocoStudioHelperScene:init()
    local testlayer = Testlayer.create()
    testlayer:ignoreAnchorPointForPosition(false)
    testlayer:setAnchorPoint(0.5, 0.5)
    testlayer:setPosition(VisibleRect:center())
    self:addChild(testlayer)
end