module("core.tools", package.seeall)

---@field [#parent=tools] VisibleRect#VisibleRect VisibleRect
core.tools.VisibleRect = require_ex("core.tools.VisibleRect")
---@field [#parent=tools] CocoStudioHelper#CocoStudioHelper CocoStudioHelper
core.tools.CocoStudioHelper = require_ex("core.tools.CocoStudioHelper")
---@field [#parent=tools] TouchHelper#TouchHelper TouchHelper
core.tools.TouchHelper = require_ex("core.tools.TouchHelper")
---@field [#parent=tools] LoadDelay#LoadDelay LoadDelay
core.tools.LoadDelay = require_ex("core.tools.LoadDelay")
---@field [#parent=tools] SensitiveWordHelper#SensitiveWordHelper SensitiveWordHelper
core.tools.SensitiveWordHelper = require_ex("core.tools.SensitiveWordHelper")
---@field [#parent=tools] TileMapHelper#TileMapHelper TileMapHelper
core.tools.TileMapHelper = require_ex("core.tools.TileMapHelper")
---@field [#parent=tools] Helper#Helper Helper
core.tools.Helper = require_ex("core.tools.Helper")