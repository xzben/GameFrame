-------------------------------------------------------------------------------
-- @file luaBridge.lua
--
-- @ author xzben 2015/05/21
--
-- lua 调用Java 或 object C
-------------------------------------------------------------------------------

local LuaBridge = class("LuaBridge", core.EventDispatcher)

local s_win_clipboard = {}  --win32 情况下模拟

function LuaBridge:ctor()

end

function LuaBridge:addTwoNumbers(a, b)
    return a + b, "Win32"
end

function LuaBridge:copyToClipboard( text )
    table.insert(s_win_clipboard, text)
end

function LuaBridge:pasteFromClipboard( )
    if #s_win_clipboard < 0 then return "empty" end

    return table.remove(s_win_clipboard)
end

function LuaBridge:callbackLua()

end

return LuaBridge