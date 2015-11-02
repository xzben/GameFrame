module("prime", package.seeall)

---@field [#parent=prime] common#common common
require_ex("prime.common.common")

---@field [#parent=encrypt] EncryptScene#EncryptScene EncryptScene
prime.EncryptScene = require_ex("prime.encrypt.EncryptScene")
---@field [#parent=network] NetworkScene#NetworkScene NetworkScene
prime.NetworkScene = require_ex("prime.network.NetworkScene")
---@field [#parent=prime] LuaBridge#LuaBridge LuaBridge
prime.LuaBridgeScene = require_ex("prime.luaBridge.LuaBridgeScene")
---@field [#parent=prime] LauchScene#LauchScene LauchScene
prime.LauchScene = require_ex("prime.lauchScene.LauchScene")



