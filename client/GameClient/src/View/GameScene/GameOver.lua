-------------------------------------------------------------------------------
-- @file GameScene.lua 
--
--
-- 游戏主场景
--
-------------------------------------------------------------------------------

GameOver = GameOver or class("GameOver", VBase)


function GameOver.create(win, score, record)
	return GameOver.extend(cc.LayerColor:create(cc.c4b(255, 255, 255, 100)), win, score, record)
end

function GameOver:ctor(win, score, record)
	self._score = score
	self._record = record
	self._win = win

	local function handlercallback(event)
        if "enter" == event then
            self:on_enter()
        elseif "exit" == event then
            self:on_exit()
        end
    end
    self:registerScriptHandler(handlercallback)	
end

function GameOver:on_enter( )
	self:init()
end

function GameOver:on_exit( )

end

function GameOver:tryAgain()
    GSession:replaceScene(GameScene.create())
end

function GameOver:init()
    TouchHelper:add_touch_listener( self, {function() return true end}, false, true)

	local visible_size = VisibleRect:getVisibleSize()
	
	local posY = visible_size.height - 200
	local posX = visible_size.width/2
	local spKuang = cc.Sprite:create("game/game.png", resRect.GameOverKuang)
	spKuang:ignoreAnchorPointForPosition(false)
    spKuang:setAnchorPoint(cc.p(0.5, 1))
    spKuang:setPosition(cc.p(posX, posY))
    self:addChild(spKuang)
    posY = posY - spKuang:getContentSize().height - 50

    local spTitle = nil
    if self._win then
        spTitle = cc.Sprite:create("game/game.png", resRect.GameWinTitle)
    else
        spTitle = cc.Sprite:create("game/game.png", resRect.GameLostTitle)
    end
    spTitle:ignoreAnchorPointForPosition(false)
    spTitle:setAnchorPoint(0.5, 1)
    spTitle:setPosition(cc.p(spKuang:getContentSize().width/2, spKuang:getContentSize().height-20))
    spKuang:addChild(spTitle)

    local lblRecord = cc.LabelBMFont:create(tostring(self._record),  "game/bit.fnt")
    lblRecord:ignoreAnchorPointForPosition(false)
    lblRecord:setAnchorPoint(0, 0.5)
    lblRecord:setPosition(cc.p(spKuang:getContentSize().width/2 - 30, 25))
    spKuang:addChild(lblRecord)

    local lblScore = cc.LabelBMFont:create(tostring(self._score),  "game/bit.fnt")
    lblScore:ignoreAnchorPointForPosition(false)
    lblScore:setAnchorPoint(0.5, 0)
    lblScore:setPosition(cc.p(spKuang:getContentSize().width/2-10, 60))
    lblScore:setScale(1.5)
    spKuang:addChild(lblScore)

    local rect = nil
    if self._win then
        rect = resRect.menuGoOn
    else
        rect = resRect.menuAgain
    end
    local itemAgain     = createSpriteMenuItem("game/game.png", rect, GameOver.tryAgain, self)
    itemAgain:ignoreAnchorPointForPosition(false)
    itemAgain:setAnchorPoint(cc.p(0.5, 1))
    itemAgain:setPosition(cc.p(posX, posY))

    local menu = cc.Menu:create(itemAgain);
    self:addChild(menu);
    menu:setContentSize(visible_size)
    menu:ignoreAnchorPointForPosition(false)
    menu:setAnchorPoint(cc.p(0.5, 0.5))
    menu:setPosition(cc.p(visible_size.width/2, visible_size.height/2))


end
