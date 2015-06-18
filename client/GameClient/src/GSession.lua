-------------------------------------------------------------------------------
-- @file GSession.lua
--
-- @ author xzben 2014/05/16
--
-- 本文见存放整个游戏的控制逻辑
-------------------------------------------------------------------------------
require_ex("Data.MPlayer")

Session = Session or class("Session", VBase)
local scheduler = cc.Director:getInstance():getScheduler()
local director = cc.Director:getInstance()
--------------------- scene tags ------------------------------
local TAG_SCENE = 1


--------------------- scene zorders ---------------------------
local ZORDER_SCENE = 1


---------------------------------------------------
function Session.create()
	return Session.extend(cc.Scene:create())	
end

function Session:ctor()
    self._needRemoveUnusedCached = false
    self._nowRemoveUnusedCached = false
	self._curRunningScene = nil
    self._keypadbackListener = {}
    self._keypadmenuListener = {}

    self._player = MPlayer.new()
    self._audioManager = nil
	self:init()
end

function Session:initFileUtils()
    
end

function Session:initDirector()
    -- initialize director
    local glview = director:getOpenGLView()
    
    local mySize = cc.size(512, 960)
    if nil == glview then
        glview = cc.GLViewImpl:createWithRect("GameClient", cc.rect(0, 0, mySize.width, mySize.height))
        director:setOpenGLView(glview)
    end
    
    glview:setDesignResolutionSize(mySize.width, mySize.height, cc.ResolutionPolicy.FIXED_WIDTH)

    --turn on display FPS
    director:setDisplayStats(true)

    --set FPS. the default value is 1.0/60 if you don't call this
    director:setAnimationInterval(1.0 / 60)
end

function Session:replaceScene( newScene )
	if self._curRunningScene then
		self._curRunningScene:removeFromParent()
		self._curRunningScene = nil
	end

	self._curRunningScene = newScene
	self:addChild(newScene, ZORDER_SCENE, TAG_SCENE)

	self:setNeedToRemoveUnusedCached(true)
end

function Session:runWithScene( newScene )
	self:replaceScene(newScene)
end

function Session:init()
    self:initFileUtils();
	self:initDirector();
    self:registerKeypadManager()

    local function update(dt)
        self:update(dt)
    end
    scheduler:scheduleScriptFunc(update, 0, false)
end

function Session:exitGame()
    cc.Director:getInstance():endToLua()
end

function Session:lauchScene()
    require_ex("View.LauchScene.LauchScene")
    --require_ex("Audio.AudioManager")
    if director:getRunningScene() then
        director:replaceScene(self)
    else
        director:runWithScene(self)
    end
    
    --self._audioManager = AudioManager.create()
    
    local scene = LauchScene.create()
    if scene then
    	self:replaceScene( scene )
    end
end

---------------------------内存资源释放 相关管理逻辑 -------------------------------------------
function Session:setNeedToRemoveUnusedCached( isNeedRemove )
    self._needRemoveUnusedCached = isNeedRemove
end

function Session:update(dt)
    --延迟一针移除 cached 资源使场景切换的时候更加快速
    if self._nowRemoveUnusedCached then
        self._nowRemoveUnusedCached = false

        director:purgeCachedData()
    end

    if self._needRemoveUnusedCached then
        self._nowRemoveUnusedCached = true
        self._needRemoveUnusedCached = false
    end
end
---------------------------keypad 相关管理逻辑 ----------------------------------------------
function Session:registerKeypadManager()
    local function onKeyReleased(keyCode, event)
        if keyCode == cc.KeyCode.KEY_BACK then
            self:handleKeybackClicked()
        elseif keyCode == cc.KeyCode.KEY_MENU  then
            self:handleKeyMenuClicked()
        end
    end
    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
    self._keypadbackListener = {}
    self._keypadmenuListener = {}
end

function Session:registerKeybackListener(func, owner)
    if not func then return end
    table.insert(self._keypadbackListener, 1, { func = func, owner = owner} )
end

function Session:unregisterKeybackListener(func, owner)
    if not func then return end
    local listener = table.remove(self._keypadbackListener, 1)
    assert(listener.func == func and listener.owner == owner, "Session:unregisterKeybackListener unregister a no match")
end

function Session:registerKeyMenuListener(func, owner)
    if not func then return end
    table.insert(self._keypadmenuListener, 1, { func = func, owner = owner} )
end

function Session:unregisterKeyMenuListener(func, owner)
    if not func then return end
    local listener = table.remove(self._keypadmenuListener, 1)
    assert(listener.func == func and listener.owner == owner, "Session:unregisterKeybackListener unregister a no match")
end

function Session:handleKeybackClicked()
    local listener = self._keypadbackListener[1]
    if listener then
        listener.func(listener.owner)
    end
end

function Session:handleKeyMenuClicked()
    local listener = self._keypadmenuListener[1]
    if listener then
        listener.func(listener.owner)
    end
end
-----------------------------------------------------------------------------------------
GSession = GSession or Session.create()

function RequestEvent( event, ...)
    GSession:dispatch_event(event, ...)
end

function HandleRequestEvent(event, func, ower)
    GSession:add_listener(event, func, ower)
end