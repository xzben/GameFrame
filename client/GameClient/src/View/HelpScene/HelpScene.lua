-------------------------------------------------------------------------------
-- @file HelpScene.lua 
--
--
-- 游戏初始加载场景
--
-------------------------------------------------------------------------------
HelpScene = HelpScene or class("HelpScene", VBase)

function HelpScene.create()
	return HelpScene.extend(cc.Scene:create())
end

function HelpScene:ctor()


end

function HelpScene:on_enter( )
	self:init()
end

function HelpScene:on_exit( )

end

function HelpScene:start()
    GSession:replaceScene(LauchScene.create())
end

function HelpScene:handleKeyBackClicked()
    self:start()
end

function HelpScene:init()
    local visible_size = VisibleRect:getVisibleSize()
    local bg = cc.Sprite:create("bg.jpg");
    bg:setAnchorPoint(cc.p(0.5, 0));
    bg:setPosition(cc.p(visible_size.width/2, 0));
    self:addChild(bg);

    local pageView = ccui.PageView:create()
    pageView:setContentSize(visible_size)
    pageView:setTouchEnabled(true)
    pageView:ignoreAnchorPointForPosition(false)
    pageView:setAnchorPoint(cc.p(0.5, 0.5))
    pageView:setPosition(cc.p(visible_size.width/2, visible_size.height/2))
    self:addChild(pageView)
    
    local imgName = {
        "menu/menu.png",
        "menu/menu.png",
        "menu/menu2.png"
    }
    for i = 1, 3, 1 do
        local layout = ccui.Layout:create()
        layout:setContentSize(visible_size)

        local sp = cc.Sprite:create(imgName[i], resRect.helpImage[i])
        sp:ignoreAnchorPointForPosition(false)
        sp:setAnchorPoint(0.5, 0.5)
        sp:setPosition(cc.p(visible_size.width/2, visible_size.height/2+50))
        layout:addChild(sp)

        if i == 3 then
            local itemStart     = createSpriteMenuItem("menu/menu.png", resRect.menuStart, HelpScene.start, self)
            itemStart:ignoreAnchorPointForPosition(false)
            itemStart:setAnchorPoint(cc.p(0.5, 1))
            itemStart:setPosition(cc.p(visible_size.width/2, 200))
            
            local menu = cc.Menu:create(itemStart);
            layout:addChild(menu);
            menu:setContentSize(visible_size)
            menu:ignoreAnchorPointForPosition(false)
            menu:setAnchorPoint(cc.p(0.5, 0.5))
            menu:setPosition(cc.p(visible_size.width/2, visible_size.height/2))
        end
        pageView:addPage(layout)
    end
end