-------------------------------------------------------------------------------
-- @file LauchScene.lua 
--
--
-- 游戏初始加载场景
--
-------------------------------------------------------------------------------
local NetworkScene = class("NetworkScene", prime.common.VBase)

function NetworkScene.create()
	return NetworkScene.extend(cc.Scene:create())
end

function NetworkScene:ctor()
	self:init()
end

function NetworkScene:on_enter( )
	
end

function NetworkScene:on_exit( )
	self:destroy()
end

function NetworkScene:handleKeyBackClicked()
    game.session():popScene()
end

function NetworkScene:init()
    local person = {
        name = "xiezhunben",
        passwd = "1234567",
        id = 0,
    }
    local buffer = game.instance():network():encode("Proto.Person", person)
    print("encode buffer: ", buffer)
    local decode, typename, typename2 = game.instance():network():decode(buffer)
    
    if decode then
        print("message_handler, typename:"..typename, decode)
        print("decode person   name:", decode.name)
        print("decode person passwd:", decode.passwd)
        print("decode person     id:", decode.id)
    else
        print("proto decode error!!!!!!! typename:", typename2)
    end

    local visibleSize = core.VisibleRect:getVisibleSize()
    local title = ccui.Text:create()
    title:setString("please see console log!!!")
    title:setFontSize(30)
    title:setPosition(cc.p(visibleSize.width/2, visibleSize.height/2))
    self:addChild(title)
end

return NetworkScene