module("prime.common", package.seeall)

--// base
---@field [#parent=common] VBase#VBase VBase
prime.common.VBase =  require_ex("prime.common.base.VBase")
---@field [#parent=common] CBase#CBase CBase
prime.common.CBase =  require_ex("prime.common.base.CBase")
---@field [#parent=common] MBase#MBase MBase
prime.common.MBase =  require_ex("prime.common.base.MBase")
---@field [#parent=common] BaseScene#BaseScene BaseScene
prime.common.BaseScene = require_ex("prime.common.base.BaseScene")


--// controll
---@field [#parent=common] DragSprite#DragSprite DragSprite
prime.common.DragSprite = require_ex("prime.common.control.DragSprite")
---@field [#parent=common] ScrollMap#ScrollMap ScrollMap
prime.common.ScrollMap = require_ex("prime.common.control.ScrollMap")
---@field [#parent=common] SmartPageView#SmartPageView SmartPageView
prime.common.SmartPageView = require_ex("prime.common.control.SmartPageView")


