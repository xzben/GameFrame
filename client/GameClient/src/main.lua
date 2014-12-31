cc.FileUtils:getInstance():addSearchPath("src")
cc.FileUtils:getInstance():addSearchPath("res")

-- 是否使用被弃用的API接口
-- CC_USE_DEPRECATED_API = true
require "cocos.init"

local targetPlatform = cc.Application:getInstance():getTargetPlatform()

-- cclog
cclog = function(...)
    print(string.format(...))
end

function send_err_log( msg )
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open("POST", URL_ERR_LOG)
    local function onReadyStateChange()
        print(xhr.response)
    end
    xhr:registerScriptHandler(onReadyStateChange)
    local data = {
        content = msg
    }
    xhr:send(json.encode(msg))    
end

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    cclog("----------------------------------------------------")
    cclog("LUA ERROR: " .. tostring(msg) .. "\n")
    local tracestr = debug.traceback()

    if ERRLOG_SEND and ERRLOG_SEND == "send" then
        send_err_log(tracestr)
    end
    
    cclog(tracestr)
    cclog("----------------------------------------------------")
    return msg
end

-------------------------------------------------------------------------------------
-- function require_ex  require module interface for reload
--
-- param  modname     
-------------------------------------------------------------------------------------
function require_ex(modname)
    local count = 0
    if targetPlatform == cc.PLATFORM_OS_WINDOWS then
        count = collectgarbage("count")
    end
    if package.loaded[modname] then
        cclog(string.format("require_ex module[%s] reload", modname))
    end

    package.loaded[modname] = nil
    cclog(string.format("require_ex %s", modname))
    local ret = xpcall(function() require(modname) end, __G__TRACKBACK__)

    if targetPlatform == cc.PLATFORM_OS_WINDOWS then
        collectgarbage("collect")
        cclog(string.format("size of '%s': %sKB", modname, collectgarbage("count") - count)) 
    end
    return ret
end

require_ex("Configure")
require_ex("core.EventDispatcher")
require_ex("core.Helper")
require_ex("core.CocoStudioHelper")
require_ex("core.VisibleRect")
require_ex("core.TouchHelper")
require_ex("View.LauchScene.LauchScene")

local function init_file_utils()
    
end

local function init_director()
    -- initialize director
    local director = cc.Director:getInstance()
    local glview = director:getOpenGLView()
    if nil == glview then
        glview = cc.GLViewImpl:createWithRect("GameClient", cc.rect(0,0, 960, 640))
        director:setOpenGLView(glview)
    end

    glview:setDesignResolutionSize(960, 640, cc.ResolutionPolicy.NO_BORDER)

    --turn on display FPS
    director:setDisplayStats(true)

    --set FPS. the default value is 1.0/60 if you don't call this
    director:setAnimationInterval(1.0 / 60)
end


function lauch_scene()
    local scene = LauchScene.create()

    -- 
    -- 如果GSession存在，则程序正在走重新启动游戏流程，需要先将GSession销毁
    if GSession then 
        GSession:session_destroy()
        GSession = nil
        cc.Director:getInstance():replaceScene(scene)
        return 
    end

    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(scene)
    else
        cc.Director:getInstance():runWithScene(scene)
    end
end

local function main()
    collectgarbage("collect")
    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)

    init_file_utils()
    init_director()
    lauch_scene()
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    error(msg)
end