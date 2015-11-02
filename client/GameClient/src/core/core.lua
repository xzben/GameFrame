module("core", package.seeall)

local targetPlatform = cc.Application:getInstance():getTargetPlatform()
---@field [#parent=core] LuaBridge#LuaBridge LuaBridge
core.LuaBridge = require_ex("core.luaBridge.LuaBridge")

if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
    core.LuaBridge = require_ex("core.luaBridge.LuaJavaBridge")
elseif (cc.PLATFORM_OS_MAC == targetPlatform or 
        cc.PLATFORM_OS_IPHONE == targetPlatform or 
        cc.PLATFORM_OS_IPAD == targetPlatform) 
then
    core.LuaBridge = require_ex("core.luaBridge.LuaOCBridge")
end

---@field [#parent=core] EventDispatcher#EventDispatcher EventDispatcher
core.EventDispatcher = require_ex("core.EventDispatcher")
---@field [#parent=core] Session#Session Session
core.Session = require_ex("core.Session")
---@field [#parent=core] FiniteStateMachine#FiniteStateMachine FiniteStateMachine
core.FiniteStateMachine = require_ex("core.FiniteStateMachine")
---@field [#parent=core] VisibleRect#VisibleRect VisibleRect
core.VisibleRect = require_ex("core.VisibleRect")

---@field [#parent=core] tools#tools tools
require_ex("core.tools.tools")
---@field [#parent=core] struct#struct struct
require_ex("core.struct.struct")
---@field [#parent=core] network#network network
require_ex("core.network.net")