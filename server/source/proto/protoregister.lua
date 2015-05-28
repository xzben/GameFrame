local protobuf = require "protobuf"
local skynet = require "skynet"
local rootPath = skynet.getenv("root")

f = {
	rootPath.."../source/proto/Proto.pb",
}

local function register(file_name)
	local file = io.open(file_name, "rb")
	local buffer = file:read("*a")
	file:close()
	protobuf.register(buffer)
end

local function register_all()
	for _, file in pairs(f) do
		register(file)
	end
end

local protoRegister = {
	register_all = register_all,
}

return protoRegister
