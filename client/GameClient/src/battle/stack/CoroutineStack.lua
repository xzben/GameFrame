local CoroutineStack = class("CoroutineStack", battle.stack.BaseStack)


---@field  Queue#BattleBaseMessage _modelMessages
CoroutineStack._modelMessages = nil
---@field  Queue#BattleBaseMessage _viewMessages
CoroutineStack._viewMessages = nil
---@field  #coroutine _coroutine
CoroutineStack._coroutine = nil
---@field #boolean _isPause
CoroutineStack._isPause = false

function CoroutineStack:ctor()
	self._modelMessages = {}
	self._viewMessages  = {}
	self._isPause = true
end

---@function _pushModelMessage
---@param array_table#BattleBaseMessage msgs
function CoroutineStack:_pushModelMessages( msgs )
	for _, msg in ipairs(msgs or {}) do
		table.insert(self._modelMessages, msg)
	end
end

---@function _popModelMessages
---@return array_table#BattleBaseMessage msg
function CoroutineStack:_popModelMessages()
	local ret = self._modelMessages
	self._modelMessages = {}
	return ret
end

---@function _pushViewMessages
---@param array_table#BattleBaseMessage msg
function CoroutineStack:_pushViewMessages( msgs )
	for _, msg in ipairs(msgs or {}) do
		table.insert(self._viewMessages, msg)
	end
end

---@function _popViewMessages
---@return array_table#BattleBaseMessage msg
function CoroutineStack:_popViewMessages()
	local ret = self._viewMessages
	self._viewMessages = {}
	return ret
end

function CoroutineStack:reset()
	local ModelMain = require("battle.model.ModelMain"):getInstance()
	ModelMain:reset(self)
	self._coroutine = coroutine.create(function()
		local status, msg = xpcall(function()
			ModelMain:run()
		end, __G__TRACKBACK__)

		if not status then
			error(msg)
		end
	end)
end

function CoroutineStack:isPause()
	return self._isPause
end

function CoroutineStack:pause()
	self._isPause = true
	if coroutine.running() ~= self._coroutine then return end
	coroutine.yield()
end

function CoroutineStack:resume()
	self._isPause = false
	coroutine.resume(self._coroutine)
end

return CoroutineStack