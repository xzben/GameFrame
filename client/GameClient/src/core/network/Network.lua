------------------------------------------------------------------------------------
-- @file Network.lua 
-- 
-- @author xzben 2015/1/24
-- 
-- 	网络收发模块
--
------------------------------------------------------------------------------------
local Network = class("Network", core.EventDispatcher)

local NETSTATE = {
	DISCONNECT = 0,		--链接断开
	CONNECTING = 1,		--正在链接
	SUCCESS    = 2,		--链接成功
	FAILED 	   = 3,		--链接失败
}

function Network.create()
	return Network.new()
end

function Network:ctor()
	self._core 	= CNetwork.new_network() --对应c++ 导出的核心模块
	self._ip   	= nil	
	self._port 	= nil
	self._state	= NETSTATE.DISCONNECT
	self._protoRegister = core.network.ProtoRegister.new()
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
	self:updateProtos()
end

function Network:updateProtos()
	self._protoRegister:register_all()
end

function Network:handle_connect_success()
	print("Network:handle_connect_success()")
end

function Network:handle_disconnect()
	print("Network:handle_disconnect()")
end

function Network:handle_connect_failed()
	print("Network:handle_connect_failed()")
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
	if waittime == nil then waittime = 10000 end

	if self._core then
		CNetwork.connect( self._core, host, port, waittime)
	end
end

function Network:send_msg( buffer )
	if self._core then
		CNetwork.send_message( self._core, buffer )
	end
end

---@function [parent=NetWork] encode
-- @param self
-- @param #string typename  protobuf 协议名称
-- @param #table data 		protobuf 协议对应的数据
-- @return #lstring 注意返回的是一个 lstring 头部包含了协议名称信息的 lstring
function Network:encode(typename, data)
	return string.format("%03d%s",string.len(typename),typename)..protobuf.encode(typename, data)
end

---@function [parent=NetWork] decode
-- @param self
-- @param #lstring buffer   encode 对应的 lstring
-- @return table  协议解析出来的数据
function Network:decode(buffer)
	local typelen = string.sub(buffer,1,3)
    local typename = string.sub(buffer,4,3+typelen)
    local buffLen = string.len(buffer)
    local dataLen = buffLen - 3+typelen
    local data = string.sub(buffer,3+typelen+1, buffLen)

    return protobuf.decode(typename, data, dataLen), typename
end

return Network