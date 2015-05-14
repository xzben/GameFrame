-------------------------------------------------------------------------------
-- @file CocShopSubUI.lua 
--
--
-- 游戏主场景
--
-------------------------------------------------------------------------------
ShopType = {
    BAOZANG     = 1,
    ZIYUAN      = 2,
    SHIPIN      = 3,
    JUNDUI      = 4,
    FANGYU      = 5,
    DUNPAI      = 6,
}

CocShopSubUI = CocShopSubUI or class("CocShopSubUI", EventDispatcher)

function CocShopSubUI.create(type_id)
	return CocShopSubUI.extend(cc.Layer:create(), type_id)
end

function CocShopSubUI:ctor(type_id)
    self._type_id = type_id

	local function handlercallback(event)
        if "enter" == event then
            self:on_enter()
        elseif "exit" == event then
            self:on_exit()
        end
    end
    self:registerScriptHandler(handlercallback)	
end

function CocShopSubUI:on_enter( )
	self:init()
end

function CocShopSubUI:on_exit( )
	self:destroy()
end

function CocShopSubUI:control_init_btn_close( control_obj )
    local function btnCallBack(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:removeFromParent()
        end
    end
    control_obj:addTouchEventListener(btnCallBack)
end

local CocShopSubUIControlMap = {
    {tag_name = "btn_close", init_callback = CocShopSubUI.control_init_btn_close},
}

function CocShopSubUI:init()
    CocoStudioHelper.load_ui(self, "coc/ShopSubUI.csb",  CocShopSubUIControlMap)
end