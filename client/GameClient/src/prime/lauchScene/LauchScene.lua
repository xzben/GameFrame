-------------------------------------------------------------------------------
-- @file LauchScene.lua 
--
--
-- 游戏初始加载场景
--
-------------------------------------------------------------------------------
local LauchScene = class("LauchScene", prime.common.VBase)

function LauchScene.create()
	return LauchScene.extend(cc.Scene:create())
end

function LauchScene:ctor()
	self:init()
end

function LauchScene:on_enter( )
	
end

function LauchScene:on_exit( )
	--self:destroy()
end

local _allTests = {
    {name = "Encrypt Scene",                    create_func = prime.encrypt.EncryptScene.create},
    {name = "Network Scene",                    create_func = prime.network.NetworkScene.create},
    {name = "Game Map Scene",                   create_func = nil},
    {name = "Coc Demo",                         create_func = nil},
    {name = "Test TestCocoStudioHelper",        create_func = nil},
    {name = "test",                             create_func = nil},
    {name = "test",                             create_func = nil},
    {name = "test",                             create_func = nil},
    {name = "test",                             create_func = nil},
    {name = "test",                             create_func = nil},
    {name = "test",                             create_func = nil},
    {name = "test",                             create_func = nil},
    {name = "test",                             create_func = nil},
    {name = "test",                             create_func = nil},
    {name = "test",                             create_func = nil},
    {name = "test",                             create_func = nil},
}               

local TESTS_COUNT = #_allTests
local LINE_SPACE = 40

local CurPos = {x = 0, y = 0}
local BeginPos = {x = 0, y = 0}


function LauchScene:extend_goback_menu( scene )
    local function closeCallback()
        game.session():popScene()
    end

    local s = core.VisibleRect:getVisibleSize()
    local CloseItem = cc.MenuItemImage:create("ui/close.png", "ui/close.png")
    CloseItem:registerScriptTapHandler(closeCallback)
    CloseItem:setPosition(cc.p(s.width - 30, 30))

    local CloseMenu = cc.Menu:create()
    CloseMenu:setPosition(0, 0)
    CloseMenu:addChild(CloseItem)
    scene:addChild(CloseMenu, 100)
end

function LauchScene:create_menu_layer()
    local menu_layer = cc.Layer:create()

    local function closeCallback()
        game.instance():hotupdate()
    end

    local function menuCallback(tag)
        local Idx = tag - 10000

        local create_func = _allTests[Idx].create_func
        if create_func then
            local testScene = create_func()
            self:extend_goback_menu(testScene)

            if testScene then
                game.session():pushScene(testScene)
            end
        end
    end

    local s = core.VisibleRect:getVisibleSize()
    local CloseItem = cc.MenuItemImage:create("ui/close.png", "ui/close.png")
    CloseItem:registerScriptTapHandler(closeCallback)
    CloseItem:setPosition(cc.p(s.width - 30, s.height - 30))

    local CloseMenu = cc.Menu:create()
    CloseMenu:setPosition(0, 0)
    CloseMenu:addChild(CloseItem)
    menu_layer:addChild(CloseMenu)

    -- add menu items for tests
    local MainMenu = cc.Menu:create()
    local index = 0
    local obj = nil
    for index, obj in ipairs(_allTests) do
        
        local testLabel = cc.Label:createWithTTF(obj.name, "ui/fonts/arial.ttf", 24)
        testLabel:setAnchorPoint(cc.p(0.5, 0.5))
        local testMenuItem = cc.MenuItemLabel:create(testLabel)

        testMenuItem:registerScriptTapHandler(menuCallback)
        testMenuItem:setPosition(cc.p(s.width / 2, (s.height - (index) * LINE_SPACE)))
        MainMenu:addChild(testMenuItem, index + 10000, index + 10000)
    end

    MainMenu:setContentSize(cc.size(s.width, (TESTS_COUNT + 1) * (LINE_SPACE)))
    MainMenu:setPosition(CurPos.x, CurPos.y)
    menu_layer:addChild(MainMenu)

    -- handling touch events
    local function onTouchBegan(touch, event)
        BeginPos = touch:getLocation()
        return true
    end

    local function onTouchMoved(touch, event)
        local location = touch:getLocation()
        local nMoveY = location.y - BeginPos.y
        local curPosx, curPosy = MainMenu:getPosition()
        local nextPosy = curPosy + nMoveY
        local winSize = cc.Director:getInstance():getWinSize()
        if nextPosy < 0 then
            MainMenu:setPosition(0, 0)
            return
        end

        if nextPosy > ((TESTS_COUNT + 1) * LINE_SPACE - winSize.height) then
            MainMenu:setPosition(0, ((TESTS_COUNT + 1) * LINE_SPACE - winSize.height))
            return
        end

        MainMenu:setPosition(curPosx, nextPosy)
        BeginPos = {x = location.x, y = location.y}
        CurPos = {x = curPosx, y = nextPosy}
    end

    core.tools.TouchHelper:add_touch_listener(menu_layer, {onTouchBegan, nil, onTouchMoved})
    return menu_layer
end

function LauchScene:init()
   self:addChild(self:create_menu_layer()) 
end

return LauchScene