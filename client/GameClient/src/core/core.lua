module("core", package.seeall)

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