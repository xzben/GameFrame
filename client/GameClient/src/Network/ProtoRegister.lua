-------------------------------------------------------------------------------
-- @file ProtoRegister.lua  
--
-- @author	linxinjun 	2014/4/7
--
-- 注册所有的协议文件
--
-------------------------------------------------------------------------------

require("protobuf")

module("ProtoRegister", package.seeall)

f = {
    "proto/Proto.pb",
}


function registe(file)
	local tmpbuffer = cc.FileUtils:getInstance():getDataFromFile(file)
    protobuf.register(tmpbuffer)
end

  
function registe_all()
    for _, file in pairs(f) do
        registe(file)
    end
end
