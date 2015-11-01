-------------------------------------------------------------------------------
-- @file ProtoRegister.lua  
--
-- @author	linxinjun 	2014/4/7
--
-- 注册所有的协议文件
--
-------------------------------------------------------------------------------
local ProtoRegister = class("ProtoRegister")

local s_protoFiles = {
    "proto/Proto.pb",
}

local function _register(file)
	local buffer = cc.FileUtils:getInstance():getStringFromFile(file)
    protobuf.register(buffer)
end

function ProtoRegister:register_all()
	require("core.network.protobuf")
    for _, file in pairs(s_protoFiles) do
        _register(file)
    end
end

return ProtoRegister