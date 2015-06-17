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
        callback(obj, item)
    end
    item:registerScriptTapHandler(itemcallback)

    return item
end

function VBase:ctor()
	
end