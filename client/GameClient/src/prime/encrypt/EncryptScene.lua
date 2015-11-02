-------------------------------------------------------------------------------
-- @file LauchScene.lua 
--
--
-- 游戏初始加载场景
--
-------------------------------------------------------------------------------
local EncryptScene = class("EncryptScene", prime.common.VBase)

function EncryptScene.create()
	return EncryptScene.extend(cc.Scene:create())
end

function EncryptScene:ctor()
	self:init()
end

function EncryptScene:on_enter( )
	
end

function EncryptScene:on_exit( )
	self:destroy()
end

function EncryptScene:handleKeyBackClicked()
    game.session():popScene()
end

function EncryptScene:init()
    local visibleSize = core.VisibleRect:getVisibleSize()
    local normalSprite = cc.Sprite:create("ui/encrypt/bang.png")

    normalSprite:setPosition(cc.p(visibleSize.width/4, visibleSize.height/2))
    self:addChild(normalSprite)

    local lbl1 = cc.LabelTTF:create("未加密图片", "Arial", 24)
    lbl1:ignoreAnchorPointForPosition(false)
    lbl1:setAnchorPoint(cc.p(0.5, 0.5))
    lbl1:setPosition(cc.p(visibleSize.width/4, visibleSize.height/2 + normalSprite:getContentSize().height))
    self:addChild(lbl1)


    local encryptSprite = cc.Sprite:create("ui/encrypt/encrypt_bang.png")
    encryptSprite:setPosition(cc.p(visibleSize.width*3/4, visibleSize.height/2))
    self:addChild(encryptSprite)

    local lbl2 = cc.LabelTTF:create("加密图片", "Arial", 24)
    lbl2:ignoreAnchorPointForPosition(false)
    lbl2:setAnchorPoint(cc.p(0.5, 0.5))
    lbl2:setPosition(cc.p(visibleSize.width*3/4, visibleSize.height/2 + encryptSprite:getContentSize().height + 10))
    self:addChild(lbl2)
end

return EncryptScene