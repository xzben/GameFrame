cc.FileUtils:getInstance():addSearchPath("src")
cc.FileUtils:getInstance():addSearchPath("res")

-- 是否使用被弃用的API接口
-- CC_USE_DEPRECATED_API = true
require "cocos.init"
require "Configure"

local targetPlatform = cc.Application:getInstance():getTargetPlatform()

-- cclog
cclog = function(...)
    print(...)
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
    local _, ret = xpcall(function() return require(modname) end, __G__TRACKBACK__)

    if targetPlatform == cc.PLATFORM_OS_WINDOWS then
        collectgarbage("collect")
        cclog(string.format("size of '%s': %sKB", modname, collectgarbage("count") - count)) 
    end
    
    return ret
end

local function main()
    collectgarbage("collect")
    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)

    require("HotCodeInclude")
    game.instance():lauchScene()
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    error(msg)
end