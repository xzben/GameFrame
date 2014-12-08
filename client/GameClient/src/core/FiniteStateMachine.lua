-------------------------------------------------------------------------------
-- @file FiniteStateMachine.lua
--
--  有限状态机 实现
--  使用方法 一、通过 init 函数传递一个初始化的配置table，具体见 init 接口
--  使用方法 二、自己调用各个函数初始化
--  第一步: 
--		新建状态机对象:
--			1、可以对一个骨骼动画使用  FiniteStateMachine.extend(AnimationNode)
--			2、FiniteStateMachine.new()
--  第二步:
--		然后给状态机注册状态 add_state
-- 	第三步:
--		给状态机注册状态转换的事件 add_event
--  第四步:
--		给状态机设置一个初始状态 set_init_state
--  第五步:
--		状态机初始化完毕了，就可以开始调用 do_event 执行事件了
-------------------------------------------------------------------------------

FiniteStateMachine = FiniteStateMachine or class("FiniteStateMachine", EventDispatcher)

function FiniteStateMachine:ctor()
	self._state_map = {}
	self._event_map = {}
	self._cur_state = nil
end

--[[ 
init_table = {
	init_state = "初始状态",
	states = {
		[state_name] = { enter = function(self, to_state, from_state, event_name ) end, leave = function( self, to_state, from_state, event_name) end },
	},
	events = {
		[event_name] = { from = {state_name, state_name ... }, to = state_name },
	},
}
--]]
function FiniteStateMachine:init( init_table )
	assert(init_table.states, "[ FiniteStateMachine:init ] please set states table")
	assert(init_table.events, "[ FiniteStateMachine:init ] please set events table")
	assert(init_table.init_state, "[ FiniteStateMachine:init ] please set init_state")

	for state_name, callbacks in pairs( init_table.states ) do
		self:add_state(state_name, callbacks.enter, callbacks.leave)
	end

	for event_name, tbl in pairs( init_table.events ) do
		for _, state_name in pairs(tbl.from) do
			self:add_event(event_name, state_name, tbl.to )
		end
	end

	self:set_init_state(init_table.init_state)
end

-- 设置初始状态
function FiniteStateMachine:set_init_state( state_name )
	assert(self._state_map[state_name], "[ FiniteStateMachine:set_init_state ] please give a valid state_name")
	self._cur_state = state_name
	self._state_map[state_name].enter(self)
end

-- 增加状态
function FiniteStateMachine:add_state( state_name, enter_func, leave_func)
	assert(state_name and enter_func, "[ FiniteStateMachine:add_state ] please give a valid state_name and state_func")
	self._state_map[state_name] = { enter = enter_func, leave = leave_func }
end

-- 增加事件
function FiniteStateMachine:add_event(event_name, from_state, to_state )
	assert(event_name, "[ FiniteStateMachine:add_event ] please give a valid state_name and state_func")
	assert(self._state_map[from_state], "[ FiniteStateMachine:add_event ] please give a valid from_state")
	assert(self._state_map[to_state], "[ FiniteStateMachine:add_event ] please give a valid to_state")

	if not self._event_map[event_name] then
		self._event_map[event_name] = {}
	end

	self._event_map[event_name][from_state] = to_state
end

-- 执行事件
function FiniteStateMachine:do_event(event_name)
	local event = self._event_map[event_name]
	assert(event_name, "[ FiniteStateMachine:do_event ] please give a valid event_name")

	local from_state = self._cur_state
	local to_state = event[from_state]
	if to_state then
		local leave_func = self._state_map[from_state].leave
		local enter_func = self._state_map[to_state].enter

		if leave_func then
			leave_func( self, to_state, from_state, event_name )
		end

		enter_func( self, to_state, from_state, event_name )

		self._cur_state = to_state
	end
end