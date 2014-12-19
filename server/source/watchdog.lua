package.path = "../source/?.lua;" .. package.path

local skynet = require "skynet"
local netpack = require "netpack"

local gate  	--门服务
local auth 	--验证服务

local CMD = {}
local SOCKET = {}

local agent = {}

-- 有客户端链接请求过来
function SOCKET.open(fd, addr)
	print(string.format("[watchdog]: a new client connecting fd( %d ) address( %s )", fd, addr))
	
	-- 开启接收客户端的数据
	skynet.call(gate, "lua", "accpet", fd)
	
	--[[
	agent[fd] = skynet.newservice("agent")
	skynet.call(agent[fd], "lua", "start", gate, fd, proto)
	--]]
end

local function close_agent(fd)
	local a = agent[fd]
	if a then
		skynet.kill(a)
		agent[fd] = nil
	end
end

function SOCKET.close(fd)
	print("socket close",fd)
	close_agent(fd)
end

function SOCKET.error(fd, msg)
	print("socket error",fd, msg)
	close_agent(fd)
end

function SOCKET.data(fd, msg)

end

function CMD.start(conf)
	conf.auth = auth
	skynet.call(gate, "lua", "open" , conf)
end

skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, subcmd, ...)
		if cmd == "socket" then
			local f = SOCKET[subcmd]
			f(...)
			-- socket api don't need return
		else
			local f = assert(CMD[cmd])
			skynet.ret(skynet.pack(f(subcmd, ...)))
		end
	end)

	gate = skynet.newservice("xzben_gate")
	auth = skynet.newservice("auth")
end)
