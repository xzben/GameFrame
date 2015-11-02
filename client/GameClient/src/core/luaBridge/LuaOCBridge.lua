
local LuaBridge = require_ex("core.luaBridge.LuaBridge")

local LuaOCBridge = class("LuaOCBridge", LuaBridge)

local luaoc = require "cocos.cocos2d.luaoc"
local className = "LuaObjectCBridgeTest"

function LuaOCBridge:addTwoNumbers(a, b)
    local args = { num1 = a , num2 = b }
    local ok,ret  = luaoc.callStaticMethod(className,"addTwoNumbers",args)
    if not ok then
        print("luaoc error:", ret)
    else
        print("The ret is:", ret)
    end

    return ret, "OC"
end

function LuaOCBridge:callbackLua()
	local function callback(param)
        if "success" == param then
            print("object c call back success")
        end
    end
    luaoc.callStaticMethod(className,"registerScriptHandler", {scriptHandler = callback } )
    luaoc.callStaticMethod(className,"callbackScriptHandler")
end

return LuaOCBridge