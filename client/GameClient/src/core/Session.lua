-------------------------------------------------------------------------------
-- @file GSession.lua
--
-- @ author xzben 2014/05/16
--
-- 本文见存放整个游戏的控制逻辑
-------------------------------------------------------------------------------
local Session = class("Session", core.EventDispatcher)

---@field  bool#_needRemoveUnusedCached  是否需要释放无用的资源
Session._needRemoveUnusedCached = nil

---@field bool#_nowRemoveUnusedCached    标记在下一帧是否需要释放无用资源
Session._nowRemoveUnusedCached = nil

---@field stack#_keypadbackListener  存放所有返回键的监听
Session._keypadbackListener = nil

---@field stack#_keypadmenuListener  存放所有手机菜单键的监听
Session._keypadmenuListener = nil

local scheduler = cc.Director:getInstance():getScheduler()

---@function  Session 的初始化
--@param Session#self
local init = nil
---@function  初始化系统文件相关的配置
--@param Session#self
local initFileUtils = nil
---@function  初始化系统Director的配置
--@param Session#sef
local initDirector = nil
---@function 每帧清理无用资源用
local update = nil
---@function  注册手机按键的监听
--@param Session#self
local registerKeypadManager = nil
---@function  手机返回键回调接口
--@param Session#self
local handleKeybackClicked = nil
---@function  手机菜单键回调接口
--@param Session#self
local handleKeyMenuClicked = nil
---------------------------------------------------

---@static_class_function 创建一个绑定 Director 的 Session
function Session.create()
	return Session.extend(cc.Director:getInstance())
end

function Session:ctor()
    self._needRemoveUnusedCached = false
    self._nowRemoveUnusedCached = false
    self._keypadbackListener = {}
    self._keypadmenuListener = {}

    init(self)
end

---@function 切换场景，并标记需要释放无用的资源
--@param Scene#newScene  新的场景
function Session:replaceScene( newScene )
	cc.Director.replaceScene(self, newScene)
	self:setNeedToRemoveUnusedCached(true)
end

---@function 当没有场景运行的时候才能使用本接口运行一个场景
--@param  Scene#newScene 新的场景
function Session:runWithScene( newScene )
	cc.Director.runWithScene(self, newScene)
    self:setNeedToRemoveUnusedCached(true)
end

---@function 将当前运行的场景暂停运行并保存，切换到新的场景运行
--@param Scene#newScene 新的场景
function Session:pushScene( newScene )
    cc.Director.pushScene(self, newScene)
end

---@function 将当前场景退出并恢复原先暂停运行的场景并继续运行
function Session:popScene()
    cc.Director.popScene(self)
    self:setNeedToRemoveUnusedCached(true)
end

---@function 将当前场景退出，并恢复场景栈中指定index的场景继续运行
--@param number#index     index 对应的场景按 压入顺序从小到大（1-n）
--                        当 index == 0 相当于退出游戏，
--                           index == 1 相当于 popToRootScene
function Session:popToSceneStackLevel( index )
    cc.Director.popToSceneStackLevel(self, index)
    self:setNeedToRemoveUnusedCached(true)
end

---@function 退出当前场景，并恢复到场景栈中的第一个场景继续运行
function Session:popToRootScene()
    cc.Director.popToRootScene(self)
    self:setNeedToRemoveUnusedCached(true)
end

---@function 退出游戏
function Session:exitGame()
    self:endToLua()
end

---@function 标记是否需要释放无用资源
--@param bool#isNeedRemove  true 代表希望释放无用资源
function Session:setNeedToRemoveUnusedCached( isNeedRemove )
    self._needRemoveUnusedCached = isNeedRemove
end

---@function 注册手机返回键的监听
--@param function#func 监听回调函数
--@param Object#owner  当监听回调函数为对象接口时为对象的self 否则为 nil
function Session:registerKeybackListener(func, owner)
    if not func then return end
    table.insert(self._keypadbackListener, 1, { func = func, owner = owner} )
end

---@function 取消手机返回键的监听
--@param function#func 监听回调函数
--@param Object#owner  当监听回调函数为对象接口时为对象的self 否则为 nil
function Session:unregisterKeybackListener(func, owner)
    if not func then return end
    local listener = table.remove(self._keypadbackListener, 1)
    assert(listener.func == func and listener.owner == owner, "Session:unregisterKeybackListener unregister a no match")
end


---@function 注册手机菜单键的监听
--@param function#func 监听回调函数
--@param Object#owner  当监听回调函数为对象接口时为对象的self 否则为 nil
function Session:registerKeyMenuListener(func, owner)
    if not func then return end
    table.insert(self._keypadmenuListener, 1, { func = func, owner = owner} )
end

---@function 取消手机菜单键的监听
--@param function#func 监听回调函数
--@param Object#owner  当监听回调函数为对象接口时为对象的self 否则为 nil
function Session:unregisterKeyMenuListener(func, owner)
    if not func then return end
    local listener = table.remove(self._keypadmenuListener, 1)
    assert(listener.func == func and listener.owner == owner, "Session:unregisterKeybackListener unregister a no match")
end
-----------------------------------------------------------------------------------------
-- 私有接口

---@function  注册手机按键的监听
--@param Session#self
registerKeypadManager = function ( self )
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
    eventDispatcher:addEventListenerWithFixedPriority(listener, 1)
    self._keypadbackListener = {}
    self._keypadmenuListener = {}
end

---@function  手机返回键回调接口
--@param Session#self
handleKeybackClicked = function ( self )
    local listener = self._keypadbackListener[1]
    if listener then
        listener.func(listener.owner)
    end
end

---@function  手机菜单键回调接口
--@param Session#self
handleKeyMenuClicked = function ( self )
    local listener = self._keypadmenuListener[1]
    if listener then
        listener.func(listener.owner)
    end
end

---@function  Session 的初始化
--@param Session#self
init = function( self )
    initFileUtils(self);
    initDirector(self);
    registerKeypadManager(self)

    local function update_callback(dt)
        update(self, dt)
    end
    scheduler:scheduleScriptFunc(update_callback, 0, false)
end

---@function  初始化系统文件相关的配置
--@param Session#self
initFileUtils = function ( self )
    
end

---@function  初始化系统Director的配置
--@param Session#sef
initDirector = function ( self )
    -- initialize director
    local glview = self:getOpenGLView()
    
    local mySize = MIN_VIEW_SIZE
    if nil == glview then
        glview = cc.GLViewImpl:createWithRect("GameClient", cc.rect(0, 0, mySize.width, mySize.height))
        self:setOpenGLView(glview)
    end

    local screenSize = self:getWinSize()
    local resolutionSize = {};
    
    --保证适配各种尺寸的屏幕的时候总是能够保证至少有我们的设计尺寸的大小
    if screenSize.width/screenSize.height > mySize.width/mySize.height then
        resolutionSize.height = mySize.height
        resolutionSize.width = resolutionSize.height * screenSize.width / screenSize.height
    else
        resolutionSize.width = mySize.width
        resolutionSize.height = resolutionSize.width * screenSize.height / screenSize.width
    end
    cclog(string.format(" screen size [ %f | %f ] resolutionSize [ %f | %f ]", screenSize.width, screenSize.height, resolutionSize.width, resolutionSize.height))
    glview:setDesignResolutionSize(resolutionSize.width, resolutionSize.height, cc.ResolutionPolicy.SHOW_ALL)

    self:setDisplayStats(SHOW_FPS)
    self:setAnimationInterval(FPS_INTERVA)
end

---@function 每帧清理无用资源用
update = function(self, dt)
    --延迟一针移除 cached 资源使场景切换的时候更加快速
    if self._nowRemoveUnusedCached then
        self._nowRemoveUnusedCached = false

        self:purgeCachedData()
    end

    if self._needRemoveUnusedCached then
        self._nowRemoveUnusedCached = true
        self._needRemoveUnusedCached = false
    end
end

return Session