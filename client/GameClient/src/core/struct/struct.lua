module("core.struct", package.seeall)

---@field [#parent=struct] Queue#Queue Queue
core.struct.Queue = require_ex("core.struct.Queue")
---@field [#parent=struct] Stack#Stack Stack
core.struct.Stack = require_ex("core.struct.Stack")