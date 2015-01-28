------------------------------------------------------------------------------------
-- @file Network.lua 
-- 
-- @author xzben 2015/1/24
-- 
-- 	网络收发模块
--
------------------------------------------------------------------------------------
Network = Network or class("Network", EventDispatcher)

local NETSTATE = {
	DISCONNECT = 0,		--链接断开
	CONNECTING = 1,		--正在链接
	SUCCESS    = 2,		--链接成功
	FAILED 	   = 3,		--链接失败
}

function Network:ctor()
	self._core 	= CNetwork.new_network() --对应c++ 导出的核心模块
	self._ip   	= nil	
	self._port 	= nil
	self._state	= NETSTATE.DISCONNECT

	self:register_callback()
	self:init()
end

function Network:destroy()
	if self._core then
		CNetwork.delete_network(self._core)
		self._core = nil
	end
end

function Network:init()

end

function Network:handle_connect_success()

end

function Network:handle_disconnect()
	print("Network:handle_disconnect()")
end

function Network:handle_connect_failed()

end

-- 链接状态更新
function Network:handle_netstate( state )
	self._state = state
	local state_map = {
		[NETSTATE.DISCONNECT] = self.handle_disconnect,
		[NETSTATE.SUCCESS]	  = self.handle_connect_success,
		[NETSTATE.FAILED]	  = self.handle_connect_failed,
	}

	local func = state_map[state]
	if func then
		func(self)
	end
end

-- 收到消息后统一派发
function Network:handle_message( buffer )
	print(buffer)
end

function Network:register_callback()
	print(self._core)
	if self._core then
		local function state_callback( state )
			self:handle_netstate(state)
		end

		local function messsage_callback( buffer )
			self:handle_message(buffer)
		end

		CNetwork.resiger_callback( self._core, state_callback, messsage_callback)
	end
end

function Network:connect(host, port, waittime)
	if self._core then
		CNetwork.connect( self._core, host, port, waittime)
	end
end

function Network:send_msg( buffer )
	if self._core then
		CNetwork.send_message( self._core, buffer )
	end
end