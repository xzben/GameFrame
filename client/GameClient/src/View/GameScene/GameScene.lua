-------------------------------------------------------------------------------
-- @file GameScene.lua 
--
--
-- 游戏主场景
--
-------------------------------------------------------------------------------
require_ex("View.GameScene.GameOver")

local Dir = {
    UP = 1,
    DOWN = 2,
    LEFT = 3,
    RIGHT = 4,
}
local ActTime = 0.05

GameScene = GameScene or class("GameScene", VBase)
local GameView  = GameView or class("GameView", VBase)
local Cell = Cell or class("Cell")

function GameScene.create()
	return GameScene.extend(cc.Scene:create())
end

function GameScene:ctor()
    self._lblRecord = nil
    self._lblScore  = nil
    self._gameView = nil
	local function handlercallback(event)
        if "enter" == event then
            self:on_enter()
        elseif "exit" == event then
            self:on_exit()
        end
    end
    self:registerScriptHandler(handlercallback)	
end

function GameScene:on_enter( )
	self:init()
end

function GameScene:on_exit( )

end

function GameScene:restart()
    self._gameView:reset()
    self:updateScore()
end

function GameScene:gotoHome()
    GSession:replaceScene(LauchScene.create())
end

function GameScene:updateRecord()
    local record = GSession._player:getRecord()
    self._lblRecord:setString(tostring(record))
end

function GameScene:updateScore()
    local score = self._gameView._score
    --print("updateScore:", score)
    self._lblScore:setString(tostring(score))
end

function GameScene:onGameOver( sender, win )
    local ly = GameOver.create(win, self._gameView._score, GSession._player:getRecord())
    ly:setPosition(0, 0)
    self:addChild(ly)

    GSession._player:updateRecord(self._gameView._score)
end

function GameScene:init()
    local visible_size = VisibleRect:getVisibleSize()
    local bg = cc.Sprite:create("bg.jpg");
    bg:setAnchorPoint(cc.p(0.5, 0));
    bg:setPosition(cc.p(visible_size.width/2, 0));
    self:addChild(bg);

    local posY = visible_size.height - 10
    local spRecord = cc.Sprite:create("game/game.png", resRect.gameRecord)
    spRecord:ignoreAnchorPointForPosition(false)
    spRecord:setAnchorPoint(cc.p(0, 1))
    spRecord:setPosition(cc.p(0, posY))
    self:addChild(spRecord)
    posY = posY - spRecord:getContentSize().height - 50
    local lblRecord = cc.LabelBMFont:create("0",  "game/bit.fnt")
    lblRecord:ignoreAnchorPointForPosition(false)
    lblRecord:setAnchorPoint(0.5, 0)
    lblRecord:setPosition(cc.p(spRecord:getContentSize().width/2-10, 12))
    spRecord:addChild(lblRecord)
    self._lblRecord = lblRecord

    local spScore = cc.Sprite:create("game/game.png", resRect.gameScore)
    spScore:ignoreAnchorPointForPosition(false)
    spScore:setAnchorPoint(cc.p(0.5, 1))
    spScore:setPosition(cc.p(visible_size.width/2, posY ))
    self:addChild(spScore)
    posY = posY - spScore:getContentSize().height - 10

    local lblScore = cc.LabelBMFont:create("0",  "game/bit.fnt")
    lblScore:ignoreAnchorPointForPosition(false)
    lblScore:setAnchorPoint(0.5, 0)
    lblScore:setPosition(cc.p(spScore:getContentSize().width/2, 15))
    spScore:addChild(lblScore)
    self._lblScore = lblScore
    
    local gameView = GameView.create();
    gameView:ignoreAnchorPointForPosition(false)
    gameView:setAnchorPoint(cc.p(0.5, 1))
    gameView:setPosition(cc.p(visible_size.width/2, posY))
    self:addChild(gameView)
    self._gameView = gameView

    local posX = visible_size.width - 10
    posY = visible_size.height - 10

    local itemRestart   = createSpriteMenuItem("game/game.png", resRect.menuRestart, GameScene.restart, self)
    itemRestart:ignoreAnchorPointForPosition(false)
    itemRestart:setAnchorPoint(cc.p(1, 1))
    itemRestart:setPosition(cc.p(posX, posY))
    posX = posX - itemRestart:getContentSize().width -  20

    local itemHome     = createSpriteMenuItem("game/game.png", resRect.menuHome, GameScene.gotoHome, self)
    itemHome:ignoreAnchorPointForPosition(false)
    itemHome:setAnchorPoint(cc.p(1, 1))
    itemHome:setPosition(cc.p(posX, posY))

    local menu = cc.Menu:create(itemHome, itemRestart);
    self:addChild(menu);
    menu:setContentSize(visible_size)
    menu:ignoreAnchorPointForPosition(false)
    menu:setAnchorPoint(cc.p(0.5, 0.5))
    menu:setPosition(cc.p(visible_size.width/2, visible_size.height/2))

    self:updateScore()
    self:updateRecord()

    self._gameView:add_listener("updateScore", self.updateScore, self)
    self._gameView:add_listener("GameOver", self.onGameOver, self)

end
------------------------- Cell -------------------------------

function Cell.create( num )
    --local ly = cc.LayerColor:create(cc.c4b(255,0,0,100))
    local ly = cc.Layer:create()
    ly:setContentSize(cc.size(91, 91))

    return Cell.extend(ly, num)
end

function Cell:ctor( num )
    self._num = num
    self._row = nil
    self._col = nil
    self._sp  = nil

    if num ~= 0 then
        local sp = cc.Sprite:create("game/game.png", resRect[num])
        self._sp = sp

        sp:ignoreAnchorPointForPosition(false)
        sp:setAnchorPoint(0.5, 0.5)
        sp:setPosition(cc.p(self:getContentSize().width/2, self:getContentSize().height/2))
        self:addChild(sp)
    end
end

function Cell:setPos(row, col)
    self._row = row
    self._col = col
end

function Cell:merge( time )
    self._num = 2*self._num

    local sp = cc.Sprite:create("game/game.png", resRect[self._num])
    sp:ignoreAnchorPointForPosition(false)
    sp:setAnchorPoint(0.5, 0.5)
    sp:setPosition(cc.p(self:getContentSize().width/2, self:getContentSize().height/2))
    sp:setScale(0)
    self:addChild(sp)

    local tmpSp = self._sp
    self._sp = sp

    tmpSp:runAction(cc.Sequence:create(cc.ScaleTo:create(time, 0), cc.RemoveSelf:create()))
    sp:runAction(cc.ScaleTo:create(time, 1))
end

function Cell:show( time )
    if not self._sp then return end

    self._sp:setScale(0)
    self._sp:runAction(cc.ScaleTo:create(time, 1))
end
------------------------- GameView -------------------------------
function GameView.create()
    return GameView.extend(cc.Layer:create())
end

function GameView:ctor()
    self._cellbg = nil
    self._cells = nil
    self._score = 0

    self:initCell()
    local function handlercallback(event)   
        if "enter" == event then
            self:on_enter()
        elseif "exit" == event then
            self:on_exit()
        end
    end
    self:registerScriptHandler(handlercallback) 
end

function GameView:on_enter()
    self:init()
end

function GameView:on_exit()

end

function GameView:initCell()
    self._cells = {}

    for i = 0, 5 , 1 do
        self._cells[i] = {}
    end

end

function GameView:getCellPosition(x, y)
    return cc.p(21+106*(x-1) +45.5, 30+(y-1)*101 + 45.5)
end

function GameView:setCellPosition(cell, x, y)
    cell:ignoreAnchorPointForPosition(false)
    cell:setAnchorPoint(0.5, 0.5)
    cell:setPosition(self:getCellPosition(x, y))
    cell:setPos(x, y)
end


function GameView:randomCellNum()
    local person = math.random()
    if person < 0.8 then
        return 2
    else
        return 4
    end

    return 2
end

function GameView:checkPosValid(x, y)
    if self._cells[x] and self._cells[x][y] then
        return false
    end

    return true
end

function GameView:randomePos()
    local posX = math.ceil(math.random(1, 4))
    local posY = math.ceil(math.random(1, 4))

    --print("GameView:randomePos()", posY, posX)
    while not self:checkPosValid(posX, posY) do
        posX = math.ceil(math.random(1, 4))
        posY = math.ceil(math.random(1, 4))
        --print("GameView:randomePos()", posY, posX)
    end

    return posX, posY
end

function GameView:randomAddCell()
    local num = self:randomCellNum()
    local posX, posY = self:randomePos()

    local cell = Cell.create( num )
    self._cellbg:addChild(cell)
    self:setCellPosition(cell, posX, posY)
    self._cells[posX][posY] = cell
    cell:show(ActTime/2)
end

function GameView:AddCell(num, posX, posY)
    local cell = Cell.create( num )
    self._cellbg:addChild(cell)
    self:setCellPosition(cell, posX, posY)
    self._cells[posX][posY] = cell
end

function GameView:reset()
    self._cellbg:removeAllChildren()
    self:initCell()
    self._score = 0
    for row = 0, 5, 1 do
        for col = 0, 5, 1 do
            if row < 1 or row > 4 or col < 1 or col > 4 then
                self:AddCell(0, row, col)
            end
        end
    end

    math.randomseed(os.time()*math.random())
    self:randomAddCell()
    self:randomAddCell()
end


function GameView:handleMoveLeft()
    --print("GameView:handleMoveLeft()")
    self:move(cc.p(0, 1), cc.p(0, 1), cc.p(1, 0), cc.p(1, 0))
end

function GameView:handleMoveRight()
    --print("GameView:handleMoveRight()")
    self:move(cc.p(0, 1), cc.p(0, 1), cc.p(4, 0), cc.p(-1, 0))
end

function GameView:handleMoveUp()
    --print("GameView:handleMoveUp()")
    self:move(cc.p(1, 0), cc.p(1,0), cc.p(0, 4), cc.p(0, -1))
end

function GameView:handleMoveDown()
    --print("GameView:handleMoveDown()")
    self:move(cc.p(1, 0), cc.p(1,0), cc.p(0, 1), cc.p(0, 1))
end

function GameView:move(pos1, offset1, pos2, offset2)
    local tAct = ActTime

    local haveAct = false
    local maxCellNum = 0

    for i = 1, 4, 1 do
        for j = 1, 4, 1 do
            local row = pos1.x + (i-1)*offset1.x + pos2.x + (j-1)*offset2.x 
            local col = pos1.y + (i-1)*offset1.y + pos2.y + (j-1)*offset2.y

            local beforeRow = pos1.x + (i-1)*offset1.x + pos2.x + (j-2)*offset2.x 
            local beforeCol = pos1.y + (i-1)*offset1.y + pos2.y + (j-2)*offset2.y

            --print(string.format("i:j %d:%d row:col %d:%d brow:bcol %d:%d", i, j, row, col, beforeRow, beforeCol))

            local curCell = self._cells[row][col]
            local beforeCell = self._cells[beforeRow][beforeCol]

            if curCell then
                if curCell._num > maxCellNum then
                    maxCellNum = curCell._num
                end

                if not beforeCell then
                    haveAct = true

                    self._cells[beforeRow][beforeCol] = curCell
                    self._cells[row][col] = nil
                    curCell:runAction(cc.Sequence:create(cc.MoveTo:create(tAct, self:getCellPosition(beforeRow, beforeCol))))
                elseif beforeCell and beforeCell._num == curCell._num then
                    local flag = pos1.x + (i-1)*offset1.x + pos1.y + (i-1)*offset1.y
                    if not self._mergeFlag[flag] then
                        self._mergeFlag[flag] = true
                        haveAct = true

                        self._cells[beforeRow][beforeCol] = curCell
                        self._cells[row][col] = nil
                        self._score = self._score + curCell._num*2
                        local function moveEnd()
                            beforeCell:removeFromParent()
                            curCell:merge(tAct/2)
                        end
                        
                        local move = cc.MoveTo:create(tAct/2, self:getCellPosition(beforeRow, beforeCol))
                        local call = cc.CallFunc:create(moveEnd)
                        
                        curCell:runAction(cc.Sequence:create( move, call ) )
                    end
                end
            end
        end
    end

    if haveAct then
        self._canMove = true
        local function bacllback()
            self:move(pos1, offset1, pos2, offset2) 
        end
        self:runAction(cc.Sequence:create(cc.DelayTime:create(tAct), cc.CallFunc:create(bacllback)))
    else
        self._isMoving = false
        if self._canMove then
            self:randomAddCell()
            self:dispatch_event("updateScore")
        end

        if self:checkLost() then
            print("lost .......")     
            self:dispatch_event("GameOver", false)
        elseif maxCellNum >= 2048 then
            print("win .......")     
            self:dispatch_event("GameOver", true)
        end
    end
end

function GameView:checkLost()
    local offset = {
        cc.p(1, 0),
        cc.p(-1, 0),
        cc.p(0, 1),
        cc.p(0, -1),
    }

    for row = 1, 4, 1 do
        for col = 1, 4, 1 do
            for i = 1, 4, 1 do
                local curCell = self._cells[row][col]
                if not curCell then return false end

                local otherRow = row + offset[i].x
                local otherCol = col + offset[i].y
                local otherCell = self._cells[otherRow][otherCol]
                if not otherCell then return false end

                if otherCell._num == curCell._num then return false end
            end
        end
    end

    for row = 1, 4, 1 do
        local str = ""
        for col = 1, 4, 1 do
            str = str .. " " .. tostring(self._cells[row][col]._num)
        end
        print(str)
    end
    return true
end

function GameView:handleMove( direct )
    local funcMap = {
        [Dir.LEFT]  = GameView.handleMoveLeft,
        [Dir.RIGHT] = GameView.handleMoveRight,
        [Dir.UP]    = GameView.handleMoveUp,
        [Dir.DOWN]  = GameView.handleMoveDown,
    }

    local func = funcMap[direct]
    if func and not self._isMoving then
        self._isMoving = true
        self._mergeFlag = {}
        self._canMove = false
        func(self)
    end
end

function GameView:init()
    local bg = cc.Sprite:create("game/game.png", resRect.gameView);
    local bgSize = bg:getContentSize()
    self:setContentSize(bgSize)
    bg:setAnchorPoint(cc.p(0.5, 0.5));
    bg:setPosition(cc.p(bgSize.width/2, bgSize.height/2));
    self:addChild(bg);
    self._cellbg = bg
    self:reset()
    
    local beganPos = cc.p(0, 0)
    local function touch_began(touch, event)
        beganPos   = touch:getLocation()
        return true
    end

    local function touch_end(touch, event)
        local endPos  = touch:getLocation()

        local offsetX = endPos.x - beganPos.x
        local offsetY = endPos.y - beganPos.y
        
        if math.abs(offsetX) < 50 and math.abs(offsetY) < 50 then return end

        local direct = nil
        if math.abs(offsetX) > math.abs(offsetY) then
            if offsetX > 0 then
                direct = Dir.RIGHT
            else
                direct = Dir.LEFT
            end
        else
            if offsetY > 0 then
                direct = Dir.UP
            else
                direct = Dir.DOWN
            end
        end

        if direct then
            self:handleMove(direct)
        end
    end
    TouchHelper:add_touch_listener(bg, {touch_began, touch_end}, true, true)
end