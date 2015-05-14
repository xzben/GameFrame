-------------------------------------------------------------------------------
-- @file CocMainUI.lua 
--
--
-- 游戏主场景
--
-------------------------------------------------------------------------------

CocMainUI = CocMainUI or class("CocMainUI", EventDispatcher)

function CocMainUI.create()
	return CocMainUI.extend(cc.Layer:create())
end

function CocMainUI:ctor()

	local function handlercallback(event)
        if "enter" == event then
            self:on_enter()
        elseif "exit" == event then
            self:on_exit()
        end
    end
    self:registerScriptHandler(handlercallback)	
end

function CocMainUI:on_enter( )
	self:init()
end

function CocMainUI:on_exit( )
	self:destroy()
end

function CocMainUI:control_init_btn_shop( control_obj )
    local function btnCallBack(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            print(":###############################")
            local shop_layer = CocShopMainUI.create()
            shop_layer:ignoreAnchorPointForPosition(false)
            shop_layer:setAnchorPoint(0.5, 0.5)
            shop_layer:setPosition(VisibleRect:center())
            cc.Director:getInstance():getRunningScene():addChild(shop_layer)
        end
    end
    control_obj:addTouchEventListener(btnCallBack)
end

local CocMainUIControlMap = {
    {tag_name = "btn_shop", init_callback = CocMainUI.control_init_btn_shop},
}

function CocMainUI:init()
    CocoStudioHelper.load_ui(self, "coc/CocosMainUI.csb",  CocMainUIControlMap)
end