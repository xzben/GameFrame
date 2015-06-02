-------------------------------------------------------------------------------
-- @file luaBridge.lua
--
-- @ author xzben 2015/05/21
--
-- lua 调用Java 或 object C
-------------------------------------------------------------------------------

luaBridge = luaBridge or class("luaBridge", EventDispatcher)

function luaBridge:ctor()

end

function luaBridge:test()
	if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        local args = { 2 , 3}
        local sigs = "(II)I"
        local luaj = require "cocos.cocos2d.luaj"
        local className = "com/cocos2dx/sample/LuaJavaBridgeTest/LuaJavaBridgeTest"
        local ok,ret  = luaj.callStaticMethod(className,"addTwoNumbers",args,sigs)
        if not ok then
            print("luaj error:", ret)
        else
            print("The ret is:", ret)
        end

        local function callbackLua(param)
            if "success" == param then
                print("java call back success")
            end
        end
        args = { "callbacklua", callbackLua }
        sigs = "(Ljava/lang/String;I)V"
        ok = luaj.callStaticMethod(className,"callbackLua",args,sigs)
        if not ok then
            print("call callback error")
        end
    end
end