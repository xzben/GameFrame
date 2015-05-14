-------------------------------------------------------------------------------
-- @file CocShopMainUI.lua 
--
--
-- 游戏主场景
--
-------------------------------------------------------------------------------

CocShopMainUI = CocShopMainUI or class("CocShopMainUI", EventDispatcher)

function CocShopMainUI.create()
	return CocShopMainUI.extend(cc.Layer:create())
end

function CocShopMainUI:ctor()
	local function handlercallback(event)
        if "enter" == event then
            self:on_enter()
        elseif "exit" == event then
            self:on_exit()
        end
    end
    self:registerScriptHandler(handlercallback)	
end

function CocShopMainUI:on_enter( )
	self:init()
end

function CocShopMainUI:on_exit( )
	self:destroy()
end

function CocShopMainUI:open_sub_shop(type_id)
    local sub_shop_layer = CocShopSubUI.create(type_id)
    sub_shop_layer:ignoreAnchorPointForPosition(false)
    sub_shop_layer:setAnchorPoint(0.5, 0.5)
    sub_shop_layer:setPosition(VisibleRect:center())
    self:addChild(sub_shop_layer)
end

function CocShopMainUI:control_init_btn_close( control_obj )
    local function btnCallBack(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:removeFromParent()
        end
    end
    control_obj:addTouchEventListener(btnCallBack)
end

function CocShopMainUI:control_init_btn_baozhang(control_obj)
    local function btnCallBack(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
           self:open_sub_shop(ShopType.BAOZANG)
        end
    end
    control_obj:addTouchEventListener(btnCallBack)
end

function CocShopMainUI:control_init_btn_ziyuan(control_obj)
    local function btnCallBack(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
           self:open_sub_shop(ShopType.ZIYUAN)
        end
    end
    control_obj:addTouchEventListener(btnCallBack)
end

function CocShopMainUI:control_init_btn_shipin(control_obj)
    local function btnCallBack(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:open_sub_shop(ShopType.SHIPIN)
        end
    end
    control_obj:addTouchEventListener(btnCallBack)
end

function CocShopMainUI:control_init_btn_btn_jundui(control_obj)
    local function btnCallBack(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
           self:open_sub_shop(ShopType.JUNDUI)
        end
    end
    control_obj:addTouchEventListener(btnCallBack)
end

function CocShopMainUI:control_init_btn_fangyu(control_obj)
    local function btnCallBack(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
           self:open_sub_shop(ShopType.FANGYU)
        end
    end
    control_obj:addTouchEventListener(btnCallBack)
end

function CocShopMainUI:control_init_btn_dunpai(control_obj)
    local function btnCallBack(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:open_sub_shop(ShopType.DUNPAI)
        end
    end
    control_obj:addTouchEventListener(btnCallBack)
end

local CocShopMainUIControlMap = {
    {tag_name = "btn_close",    init_callback = CocShopMainUI.control_init_btn_close},
    {tag_name = "btn_baozhang", init_callback = CocShopMainUI.control_init_btn_baozhang},
    {tag_name = "btn_ziyuan",   init_callback = CocShopMainUI.control_init_btn_ziyuan},
    {tag_name = "btn_shipin",   init_callback = CocShopMainUI.control_init_btn_shipin},
    {tag_name = "btn_jundui",   init_callback = CocShopMainUI.control_init_btn_btn_jundui},
    {tag_name = "btn_fangyu",   init_callback = CocShopMainUI.control_init_btn_fangyu},
    {tag_name = "btn_hudun",    init_callback = CocShopMainUI.control_init_btn_dunpai},
}


function CocShopMainUI:init()
    CocoStudioHelper.load_ui(self, "coc/ShopMainUI.csb",  CocShopMainUIControlMap)
end