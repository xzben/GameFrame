local skynet = require "skynet"

local pool_size 	= ...
local agent_pool 	= {}
----------------------------------------------------------------------
local function create_agent()
	local ret_agent = skynet.newservice("agent")
	return ret_agent
end

local function init_pool()
	for i = 1, pool_size, 1 do
		local new_agent = create_agent()
		table.insert(agent_pool, new_agent)
	end
end

local command 		= {}
function command.get_agent()
	local ret_agent = table.remove(agent_pool)
	if nil == ret_agent then
		ret_agent = create_agent()
	end

	return ret_agent
end

function command.free_agent( agent )
	table.insert(agent_pool, agent)
end

skynet.start(function()
	skynet.dispatch("lua", function(session, address, cmd, ...)
		local f = command[cnd]
		if f then
			skynet.ret(skynet.pack(f(...)))
		else
			error(string.format("Unknown command %s", tostring(cmd)))
		end
	end)
	init_pool()
	skynet.register ".agent_pool"
end)
