-------------------------------------------------------------------------------
-- @file LauchScene.lua 
--
--
-- 游戏初始加载场景
--
-------------------------------------------------------------------------------
require_ex("HotCodeInclude")
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

function LauchScene:createBtn(sp_file_normal, sp_file_select, func, owner)
    local tmpSp1 = cc.Sprite:create(sp_file_normal)
    local tmpSp2 = cc.Sprite:create(sp_file_select)
    if sp_file_normal == sp_file_select then
        tmpSp2:setColor(cc.c3b(192, 192, 192))
    end
    
    local btn = cc.MenuItemSprite:create(tmpSp1, tmpSp2)
    local function menucallback()
        if owner then
            func(owner, btn);
        else
            func(btn)
        end
    end
    btn:registerScriptTapHandler(menucallback)

    return btn
end

function LauchScene:onExit()
    GSession:exitGame()
end

function LauchScene:onPlay()
    GSession:replaceScene(GameScene.create())
end

function LauchScene:onStore()

end

function LauchScene:onGameSetting()

end

function LauchScene:onAboutGame()

end

function LauchScene:init()
    local visible_size = VisibleRect:getVisibleSize()
    local spBg = cc.Sprite:create("menu-bg.png");
    spBg:ignoreAnchorPointForPosition(false)
    spBg:setAnchorPoint(0.5, 0.5)
    spBg:setPosition(visible_size.width/2, visible_size.height/2 - 30);
    self:addChild(spBg)
    spBg:runAction(cc.EaseElasticOut:create(cc.MoveTo:create(5, cc.p(visible_size.width/2, visible_size.height/2))));

    local spLogo = cc.Sprite:create("game-logo.png");
    spLogo:ignoreAnchorPointForPosition(false)
    spLogo:setAnchorPoint(0.5, 0.5)
    spLogo:setScale(0.8)
    spLogo:setPosition(-200, visible_size.height-160)
    self:addChild(spLogo)
    local moveTo = cc.EaseElasticOut:create(cc.MoveTo:create(1, cc.p(250, visible_size.height-150)));
    local sequence = cc.Sequence:create(
        moveTo,
        cc.CallFunc:create(function()
                local shaking = cc.EaseElasticOut:create(cc.MoveTo:create(1, cc.p(250, visible_size.height-250)));
                local shakingback = cc.EaseElasticOut:create(cc.MoveTo:create(1, cc.p(250, visible_size.height-140)));
                local shakingSeq = cc.Sequence:create(shaking, shakingback);
                spLogo:runAction(cc.RepeatForever:create(shakingSeq));
            end));
    spLogo:runAction(sequence)

    local  menu = cc.Menu:create()
    menu:ignoreAnchorPointForPosition(false)
    menu:setAnchorPoint(0.5, 0.5)
    menu:setPosition(visible_size.width/2, visible_size.height/2)
    self:addChild(menu)

    local btnExit = self:createBtn("ui/back-btn.png", "ui/back-btn.png", self.onExit, self);
    btnExit:ignoreAnchorPointForPosition(false)
    btnExit:setAnchorPoint(0, 0)
    btnExit:setPosition(cc.p(10, 10))
    menu:addChild(btnExit)

    local btnPlay = self:createBtn("play-btn.png", "play-btn-s.png", self.onPlay, self);
    menu:addChild(btnPlay)
    btnPlay:setPosition(cc.p(-200, visible_size.height));
    local btnPosX = 200
    local btnPosY = 150
    local seq = cc.Sequence:create(
            cc.EaseElasticOut:create(cc.MoveTo:create(2, cc.p(btnPosX, btnPosY))),
            cc.CallFunc:create(function()
                local shaking = cc.EaseElasticOut:create(cc.MoveTo:create(1, cc.p(btnPosX, btnPosY)));
                local shakingback = cc.EaseElasticOut:create(cc.MoveTo:create(1, cc.p(btnPosX, btnPosY-10)));
                local shakingSeq = cc.Sequence:create(shaking, shakingback);
                btnPlay:runAction(cc.RepeatForever:create(shakingSeq));
            end)
        )
    btnPlay:runAction(seq)
    local xGap = 20
    local yGap = 20

    local btnAbout = self:createBtn("about-btn.png", "about-btn-s.png", self.onStore, self);
    menu:addChild(btnAbout)
    btnAbout:setPosition(cc.p(visible_size.width-200, visible_size.height+100))  
    local actionTo = cc.EaseElasticOut:create(cc.MoveTo:create(2, cc.p(visible_size.width-250-xGap, visible_size.height-425-yGap)))
    local seq = cc.Sequence:create(
        actionTo,
        cc.CallFunc:create(function()
                local shaking = cc.EaseElasticOut:create(cc.MoveTo:create(1, cc.p(visible_size.width-255-xGap, visible_size.height-425-yGap)));
                local shakingback = cc.EaseElasticOut:create(cc.MoveTo:create(1, cc.p(visible_size.width-245-xGap, visible_size.height-425-yGap)));
                local shakingSeq = cc.Sequence:create(shaking, shakingback);
                btnAbout:runAction(cc.RepeatForever:create(shakingSeq));
        end))
    btnAbout:runAction(seq)


    local btnSetting = self:createBtn("set-btn.png", "set-btn-s.png", self.onStore, self);
    menu:addChild(btnSetting)
    btnSetting:setPosition(cc.p(200, visible_size.height-300))
    local actionTo = cc.EaseElasticOut:create(cc.MoveTo:create(2, cc.p(visible_size.width-250-xGap, visible_size.height-350-yGap)))
    local seq = cc.Sequence:create(
        actionTo,
        cc.CallFunc:create(function()
                local shaking = cc.EaseElasticOut:create(cc.MoveTo:create(1, cc.p(visible_size.width-255-xGap, visible_size.height-350-yGap)));
                local shakingback = cc.EaseElasticOut:create(cc.MoveTo:create(1, cc.p(visible_size.width-245-xGap, visible_size.height-350-yGap)));
                local shakingSeq = cc.Sequence:create(shaking, shakingback);
                btnSetting:runAction(cc.RepeatForever:create(shakingSeq));
        end))
    btnSetting:runAction(seq)


    local btnStore = self:createBtn("store-btn.png", "store-btn-s.png", self.onStore, self);
    menu:addChild(btnStore)
    btnStore:setPosition(cc.p(visible_size.width+200, visible_size.height-220))
    local actionTo = cc.EaseElasticOut:create(cc.MoveTo:create(2, cc.p(visible_size.width-250-xGap, visible_size.height-270-yGap)))
    local seq = cc.Sequence:create(
        actionTo,
        cc.CallFunc:create(function()
                local shaking = cc.EaseElasticOut:create(cc.MoveTo:create(1, cc.p(visible_size.width-255-xGap, visible_size.height-270-yGap)));
                local shakingback = cc.EaseElasticOut:create(cc.MoveTo:create(1, cc.p(visible_size.width-245-xGap, visible_size.height-270-yGap)));
                local shakingSeq = cc.Sequence:create(shaking, shakingback);
                btnStore:runAction(cc.RepeatForever:create(shakingSeq));
        end))
    btnStore:runAction(seq)

    local hero = Hero.create()
    self:addChild(hero)
    hero:ignoreAnchorPointForPosition(false)
    hero:setAnchorPoint(0.5, 0.5)
    hero:setPosition(cc.p(-100, 50))
    local seq = cc.Sequence:create(cc.MoveTo:create(10, cc.p(visible_size.width+200, 50)),
        cc.CallFunc:create(function()
            hero:setPositionX(-100)
            end))
    hero:runAction(cc.RepeatForever:create(seq))

    local particle = cc.ParticleSystemQuad:create("circle_particle.plist")
    particle:setPosition(800, 100)
    self:addChild(particle)
end















