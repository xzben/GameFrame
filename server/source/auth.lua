--
-- 	验证客户端链接
--
local skynet = require "skynet"
local queue  = require "skynet.queue"
local locker = queue()

local command 		= {}


local function auth_ok( fd )

end

function command.data(fd, msg)
	-- 保证消息按顺序执行
	locker(function()
	

				
	end)

end

skynet.start(function()
	skynet.dispatch("lua", function(session, address, cmd, ...)
		local f = command[cmd]
		if f then
			skynet.ret(skynet.pack(f(...)))
		else
			error(string.format("Unknown command %s", tostring(cmd)))
		end
	end)
end)
