
local LuaBridge = require_ex("core.luaBridge.LuaBridge")

local LuaJavaBridge = class("LuaJavaBridge", LuaBridge)

local luaj = require "cocos.cocos2d.luaj"
local className = "com/xzben/LuaJavaBridge"

function LuaJavaBridge:addTwoNumbers(a, b)
    local args = { a , b}
    local sigs = "(II)I"
    local ok, ret  = luaj.callStaticMethod(className,"addTwoNumbers",args,sigs)
    if not ok then
        cclog("luaj error:", ret)
    else
        cclog("luaj The ret is:", ret)
    end

    return ret, "Java"
end

function LuaJavaBridge:copyToClipboard( text )
    local args = { text }
    local sigs = "(Ljava/lang/String;)V"
    local ok, ret  = luaj.callStaticMethod(className,"copyToClipboard",args,sigs)
    if not ok then
        cclog("error copyToClipboard : "..text)
    else
        cclog("succes copyToClipboard : "..text)
    end
end

function LuaJavaBridge:pasteFromClipboard( )
    local args = {}
    local sigs = "()Ljava/lang/String;"
    local ok, ret  = luaj.callStaticMethod(className,"pasteFromClipboard",args,sigs)
    if not ok then
        cclog("error pasteFromClipboard : "..ret)
        ret = ""
    else
        cclog("succes pasteFromClipboard : "..ret)
    end

    return ret
end

function LuaJavaBridge:callbackLua()
	local function callbackLua(param)
        if "success" == param then
            cclog("java call back success")
        end
    end
    args = { "callbacklua", callbackLua }
    sigs = "(Ljava/lang/String;I)V"
    ok = luaj.callStaticMethod(className,"callbackLua",args,sigs)
    if not ok then
        cclog("call callback error")
    end
end

return LuaJavaBridge