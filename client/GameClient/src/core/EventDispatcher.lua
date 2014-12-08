--[[
	本文件存放的是 观察者模式实现
--]]

EventDispatcher = class("EventDispatcher")
local scheduler = cc.Director:getInstance():getScheduler()
local LISTENER_OWNER = "__listener_owner__"

function EventDispatcher:ctor()
	self._listener_map = {}  -- 存储结构为 [type][owner][listener]
	self._timeout_tag = 1  	 -- 定时器ID 产生的累计器
	self._timeouts = {}      -- 存储所有当前产生的定时器 
	self._target = self 	 -- 将会在事件派发的时候作为事件的sender传递给回调函数
end

function EventDispatcher:get_target()
	return self._target
end

function EventDispatcher:set_target( target )
	local old_target = self._target

	self._target = target

	return old_target
end

-- 注册要监听的事件类型，并注册回调函数
function EventDispatcher:add_listener(type, listener, owner)
	if type == nil or listener == nil then
		return false
	end

	if not self._listener_map[type] then
		self._listener_map[type] = {}
	end

	local owner = owner or LISTENER_OWNER
	if not self._listener_map[type][owner] then
		self._listener_map[type][owner] = {}
	end

	self._listener_map[type][owner][listener] = { listener = listener, owner = owner }

	return true
end

function EventDispatcher:dispatch_event(type, ... )
	if type == nil then
		return false
	end

	local type_events = self._listener_map[type] or {}
	for _, owner_listener in pairs(type_events) do
		for _, owner_listener_item in pairs(owner_listener) do
			local listener = owner_listener_item.listener
			local owner = owner_listener_item.owner

			if listener then
				if owner then
					listener(owner, self._target, ...)
				else
					listener(self._target, ...)
				end
			end
		end
	end

end

function EventDispatcher:remove_owner_listener( target_owner )
	if target_owner == nil then return end

	for type, owners in pairs(self._listener_map) do
		owners[target_owner] = nil
	end

end

function EventDispatcher:remove_type_listener( type )
	if type == nil then return end

	self._listener_map[type] = nil
end

function EventDispatcher:remove_listener(type, listener, owner )
	local owner = owner or LISTENER_OWNER

	if not self._listener_map[type] then return end
	if not self._listener_map[type][owner] then return end 

	self._listener_map[type][owner][listener] = nil
end

-----------------------------------------------------------------
-- 定时器功能
function EventDispatcher:get_cur_tag()
	local ret = self._timeout_tag
	self._timeout_tag = ret + 1

	return ret
end

function EventDispatcher:timeout(delay, func, ...)
	if delay <= 0 then
		func(...)
	else
		local cur_tag = self:get_cur_tag()
		local params = {...}

		local id = scheduler:scheduleScriptFunc(function()
			self:remove_timeout(cur_tag)
			func(unpack(params))
		end, delay, false)
		self._timeouts[cur_tag] = {id = id, tag = tag}
	end
end

function EventDispatcher:remove_timeout( tag )
	local value = self._timeouts[tag]
	scheduler:unscheduleScriptEntry(value.id)
	self._timeouts[tag] = nil
end

function EventDispatcher:clear_timeout()
	for _, value in pairs(self._timeouts) do
		scheduler:unscheduleScriptEntry(value.id)
	end
end

function EventDispatcher:destroy()
	self:clear_timeout()
end