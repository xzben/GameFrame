module("core.network", package.seeall)

---@field [#parent=network] ProtoRegister#ProtoRegister ProtoRegister
core.network.ProtoRegister = require_ex("core.network.ProtoRegister")
---@field [#parent=network] Network#Network Network
core.network.Network = require_ex("core.network.Network")
