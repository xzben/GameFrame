--
-- 	验证客户端链接
--
local skynet = require "skynet"

local command 		= {}

skynet.start(function()
	skynet.dispatch("lua", function(session, address, cmd, ...)
		local f = command[cnd]
		if f then
			skynet.ret(skynet.pack(f(...)))
		else
			error(string.format("Unknown command %s", tostring(cmd)))
		end
	end)

	skynet.register ".auth"
end)
