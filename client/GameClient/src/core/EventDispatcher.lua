--[[
	本文件存放的是 观察者模式实现
--]]

local EventDispatcher = class("EventDispatcher")

---@field [parent#EventDispatcher]  map_table [type][owner][listener] = { listener = , owner = }#
EventDispatcher._listener_map = nil

---@field [parent#EventDispatcher]  number#number 定时器id累计
EventDispatcher._timeout_tag = nil

---@field [parent#EventDispatcher]  map_table [tag] = { id = , tag = } #number 所有的定时器
EventDispatcher._timeouts = nil

---@field [parent#EventDispatcher]  Object#Object 事件派发时传递给接收者的 sender
EventDispatcher._target = nil

local LISTENER_OWNER = "__listener_owner__"

---@function 获取EventDispatcher对象当前的tag值
--@param EventDispatcher#self  EventDispatcher对象
--@return  当前可用的tag值
local get_cur_tag = nil

function EventDispatcher:ctor()
	self._listener_map = {}
	self._timeout_tag = 1
	self._timeouts = {}
	self._target = self
end


function EventDispatcher:get_target()
	return self._target
end

function EventDispatcher:set_target( target )
	local old_target = self._target

	self._target = target

	return old_target
end

---@function 监听本对象的事件
--@param  anytype#type  		监听事件的类型value，可以为任意类型
--@param  function#listener 	监听回调函数
--@param  Object#owner 			当listener为对象方法时，owner即为它的self
function EventDispatcher:add_listener(type, listener, owner)
	if type == nil or listener == nil then
		return false
	end

	if not self._listener_map[type] then
		self._listener_map[type] = {}
	end

	local owner_key = owner or LISTENER_OWNER
	if not self._listener_map[type][owner_key] then
		self._listener_map[type][owner_key] = {}
	end

	self._listener_map[type][owner_key][listener] = { listener = listener, owner = owner }

	return true
end

---@function 派发指定类型的事件，所有监听此事件的接口都会被回调
--@param  anytype#type  一个事件类型
--@param  ...  传递给回调函数的参数
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

---@function 删除指定对象的所有监听
--@param  Object#target_owner   监听事件的对象
function EventDispatcher:remove_owner_listener( target_owner )
	if target_owner == nil then return end

	for type, owners in pairs(self._listener_map) do
		owners[target_owner] = nil
	end

end

---@function 删除指定类型的所有事件监听
--@param type  事件类型
function EventDispatcher:remove_type_listener( type )
	if type == nil then return end

	self._listener_map[type] = nil
end

---@function 删除指定接口的监听
--@param anytyep#type 		监听的类型
--@param function#listener 	监听的回调
--@param Object#owner  		监听回调所属的对象 self
function EventDispatcher:remove_listener(type, listener, owner )
	local owner = owner or LISTENER_OWNER

	if not self._listener_map[type] then return end
	if not self._listener_map[type][owner] then return end 

	self._listener_map[type][owner][listener] = nil
end

---@function 增加一个定时器只会执行一次
--@param  number#delay 		多少秒后触发
--@param  function#func   	定时器回调函数
--@param  ...  传递给回调函数的参数列表
--@return 返回生成的定时的tag
function EventDispatcher:timeout(delay, func, ...)
	local cur_tag = -1
	if delay <= 0 then
		func(...)
	else
		cur_tag = get_cur_tag(self)
		local params = {...}

		local id = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
			self:remove_timeout(cur_tag)
			func(unpack(params))
		end, delay, false)
		self._timeouts[cur_tag] = {id = id, tag = tag}
	end

	return cur_tag
end

---@function 删除指定的定时器
--@param number#tag  调用 timeout 接口返回的 tag 值 
function EventDispatcher:remove_timeout( tag )
	local value = self._timeouts[tag]
	cc.Director:getInstance():getScheduler():unscheduleScriptEntry(value.id)
	self._timeouts[tag] = nil
end

---@function 清除掉所有的定时器
function EventDispatcher:clear_timeout()
	for _, value in pairs(self._timeouts) do
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(value.id)
	end
	self._timeouts = {}
	self._timeout_tag = 1
end

---@function 清除掉所有的定时器
function EventDispatcher:clear_listener()
	self._listener_map = {}
end

---@function 清除接口
function EventDispatcher:destroy()
	self:clear_timeout()
	self:clear_listener()
end

---@function 获取EventDispatcher对象当前的tag值
--@param EventDispatcher#self  EventDispatcher对象
--@return  当前可用的tag值
get_cur_tag = function(self)
	local ret = self._timeout_tag
	self._timeout_tag = ret + 1

	return ret
end

return EventDispatcher