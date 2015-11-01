module("prime", package.seeall)

---@field [#parent=prime] common#common common
require_ex("prime.common.common")
---@field [#parent=prime] encrypt#encrypt encrypt
require_ex("prime.encrypt.encrypt")
---@field [#parent=prime] network#network network
require_ex("prime.network.network")
---@field [#parent=prime] LauchScene#LauchScene LauchScene
prime.LauchScene = require_ex("prime.lauchScene.LauchScene")



