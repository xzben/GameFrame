-------------------------------------------------------------------------------
-- @file VBase.lua
--
-- @ author xzben 2015/05/19
--
-- 所有显示View的base类
-------------------------------------------------------------------------------

VBase = VBase or class("VBase", EventDispatcher)

function createSpriteMenuItem(img, rect, callback, obj)
    local sprite1 = cc.Sprite:create(img, rect);
    local sprite2 = cc.Sprite:create(img, rect);
    sprite2:setColor(cc.c3b(192, 192, 192))
    
    local item = cc.MenuItemSprite:create(sprite1, sprite2);
    local function itemcallback()
        RequestEvent("playEffect", "btnClick")
        callback(obj, item)
    end
    item:registerScriptTapHandler(itemcallback)

    return item
end

function VBase:ctor()
    
	local function handlercallback(event)
        if "enter" == event then
            self:root_on_enter()
        elseif "exit" == event then
            self:root_on_exit()
        end
    end
    self:registerScriptHandler(handlercallback)
end

function VBase:root_on_enter()
    print("VBase on_enter")
    
    if self.handleKeyBackClicked then
        print("VBase:root_on_enter()")
        GSession:registerKeybackListener(self.handleKeyBackClicked, self)
    end

    if self.handleKeyMenuClicked then
        GSession:registerKeyMenuListener(self.handleKeyMenuClicked, self)
    end

    if self.on_enter then
        self:on_enter()
    end
end

function VBase:root_on_exit()
    print("VBase on_exit")
    
    if self.handleKeyBackClicked then
        GSession:unregisterKeybackListener(self.handleKeyBackClicked, self)
    end

    if self.handleKeyMenuClicked then
        GSession:unregisterKeyMenuListener(self.handleKeyMenuClicked, self)
    end

    if self.on_exit then
        self:on_exit()
    end
end