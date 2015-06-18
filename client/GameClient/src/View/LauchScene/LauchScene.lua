-------------------------------------------------------------------------------
-- @file LauchScene.lua 
--
--
-- 游戏初始加载场景
--
-------------------------------------------------------------------------------
LauchScene = LauchScene or class("LauchScene", VBase)

function LauchScene.create()
	return LauchScene.extend(cc.Scene:create())
end

function LauchScene:ctor()

end

function LauchScene:on_enter( )
	self:init()
end

function LauchScene:on_exit( )

end

function LauchScene:help( control )
    require_ex("View.HelpScene.HelpScene")
    GSession:replaceScene(HelpScene.create())
end

function LauchScene:startGame( control )
    require_ex("View.GameScene.GameScene")
    GSession:replaceScene(GameScene.create())
end

function LauchScene:music( control )
    if control._spClose then
        control._spClose:removeFromParent()
        control._spClose = nil
    else
        local sp = cc.Sprite:create("menu/menu.png", resRect.closeMusic)
        sp:ignoreAnchorPointForPosition(false)
        sp:setAnchorPoint(0.5, 0.5)
        sp:setPosition(control:getContentSize().width/2, control:getContentSize().height/2)
        control:addChild(sp)
        control._spClose = sp
    end
    
    GSession._player:switchAudio()
end

function LauchScene:pingfen( control )

end

function LauchScene:handleKeyBackClicked()
    GSession:exitGame()
end

function LauchScene:init()
    local visible_size = VisibleRect:getVisibleSize()
    local bg = cc.Sprite:create("bg.jpg");
    bg:setAnchorPoint(cc.p(0.5, 0));
    bg:setPosition(cc.p(visible_size.width/2, 0));
    self:addChild(bg);

    local logo = cc.Sprite:create("menu/menu.png", resRect.logo)
    logo:setPosition(cc.p(visible_size.width/2, visible_size.height - 200))
    self:addChild(logo)

    local posX = visible_size.width - 10
    local posY = visible_size.height - 10
    local itemPingfen   = createSpriteMenuItem("menu/menu.png", resRect.menuQueen, LauchScene.pingfen, self)
    itemPingfen:ignoreAnchorPointForPosition(false)
    itemPingfen:setAnchorPoint(cc.p(1, 1))
    itemPingfen:setPosition(cc.p(posX, posY))
    posX = posX - itemPingfen:getContentSize().width -  20

    local itemMusic     = createSpriteMenuItem("menu/menu.png", resRect.menuMusic, LauchScene.music, self)
    itemMusic:ignoreAnchorPointForPosition(false)
    itemMusic:setAnchorPoint(cc.p(1, 1))
    itemMusic:setPosition(cc.p(posX, posY))
    if not GSession._player:isMusicOpen() then
        local sp = cc.Sprite:create("menu/menu.png", resRect.closeMusic)
        sp:ignoreAnchorPointForPosition(false)
        sp:setAnchorPoint(0.5, 0.5)
        sp:setPosition(itemMusic:getContentSize().width/2, itemMusic:getContentSize().height/2)
        itemMusic:addChild(sp)
        itemMusic._spClose = sp
    end

    posX = visible_size.width/2
    posY = visible_size.height - 400
    local itemHelp      = createSpriteMenuItem("menu/menu.png", resRect.menuHelp, LauchScene.help, self)
    itemHelp:ignoreAnchorPointForPosition(false)
    itemHelp:setAnchorPoint(cc.p(0.5, 0.5))
    itemHelp:setPosition(cc.p(posX, posY))
    posY = posY  - itemHelp:getContentSize().height -   50

    local itemStart     = createSpriteMenuItem("menu/menu.png", resRect.menuStart, LauchScene.startGame, self)
    itemStart:ignoreAnchorPointForPosition(false)
    itemStart:setAnchorPoint(cc.p(0.5, 0.5))
    itemStart:setPosition(cc.p(posX, posY))

    local menu = cc.Menu:create(itemHelp, itemStart, itemPingfen, itemMusic);
    self:addChild(menu);
    menu:setContentSize(visible_size)
    menu:ignoreAnchorPointForPosition(false)
    menu:setAnchorPoint(cc.p(0.5, 0.5))
    menu:setPosition(cc.p(visible_size.width/2, visible_size.height/2))
end