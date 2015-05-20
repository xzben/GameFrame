-------------------------------------------------------------------------------
-- @file GSession.lua
--
-- @ author xzben 2014/05/16
--
-- 本文见存放整个游戏的控制逻辑
-------------------------------------------------------------------------------

Session = Session or class("Session", VBase)

--------------------- scene tags ------------------------------
local TAG_SCENE = 1


--------------------- scene zorders ---------------------------
local ZORDER_SCENE = 1


---------------------------------------------------
function Session.create()
	return Session.extend(cc.Scene:create())	
end

function Session:ctor()
	self._curRunningScene = nil;
	self._director = cc.Director:getInstance()

	self:init()
end

function Session:session_destroy()
	
end

function Session:init_file_utils()
    
end

function Session:init_director()
    -- initialize director
    local director = self._director
    local glview = director:getOpenGLView()
    
    local mySize = cc.size(960, 640)
    if nil == glview then
        glview = cc.GLViewImpl:createWithRect("GameClient", cc.rect(0, 0, mySize.width, mySize.height))
        director:setOpenGLView(glview)
    end

    local screenSize = cc.Director:getInstance():getWinSize()
    local resolutionSize = {};

    if screenSize.width/screenSize.height > mySize.width/mySize.height then
        resolutionSize.height = mySize.height
        resolutionSize.width = resolutionSize.height * screenSize.width / screenSize.height
    else
        resolutionSize.width = mySize.width
        resolutionSize.height = resolutionSize.width * screenSize.height / screenSize.width
    end
    cclog(string.format(" screen size [ %f | %f ] resolutionSize [ %f | %f ]", screenSize.width, screenSize.height, resolutionSize.width, resolutionSize.height))
    glview:setDesignResolutionSize(resolutionSize.width, resolutionSize.height, cc.ResolutionPolicy.SHOW_ALL)

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

	self._director:getTextureCache():removeUnusedTextures();
end

function Session:runWithScene( newScene )
	self:replaceScene(newScene)
end

function Session:init()
	self:init_file_utils();
	self:init_director();
end

function Session:lauchScene()
	if self._director:getRunningScene() then
        self._director:replaceScene(self)
    else
        self._director:runWithScene(self)
    end
    
    ProtoRegister.registe_all();
    local scene = LauchScene.create()
    if scene then
    	self:replaceScene( scene )
    end
end

GSession = GSession or Session.create()

