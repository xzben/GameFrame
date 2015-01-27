-------------------------------------------------------------------------------
-- @file PhysicsScene.lua 
--
--
-- 游戏主场景
--
-------------------------------------------------------------------------------

PhysicsScene = PhysicsScene or class("GameScene", EventDispatcher)

function PhysicsScene.create()
	return PhysicsScene.extend(cc.Scene:create())
end

function PhysicsScene:ctor()

	local function handlercallback(event)
        if "enter" == event then
            self:on_enter()
        elseif "exit" == event then
            self:on_exit()
        end
    end
    self:registerScriptHandler(handlercallback)	
end

function PhysicsScene:on_enter( )
	self:init()
end

function PhysicsScene:on_exit( )
	self:destroy()
end

function PhysicsScene:init()
    -- 测试敏感字过滤
    require_ex("Profiles.propFilterWords") --262.3798828125 KB
    local crab_obj = SensitiveWordHelper.new(propFilterWords)
    -- 初始化过后可以将配置表释放，因为一般敏感字都比较多，所以配置表比较占内存。而初始化过后敏感字信息都已经存储在crab_obj中了
    propFilterWords = nil   
    collectgarbage()
    print( crab_obj:filter_word("我今天10颁奖, 你10颁奖, 他10颁奖") )
    crab_obj:destroy()
    crab_obj = nil
    collectgarbage()


    -- 测试协议
    local person = {
        name = "xiezhunben",
        passwd = "1234567",
        id = 1,
    }

    local buffer = protobuf.tpencode("Proto.Person", person)
    print("protobuf encode:", buffer)
    local decode, typename, typename2 = protobuf.tpdecode(buffer)
    if decode then
        print("message_handler, typename:"..typename, decode)
        print("decode person   name:", decode.name)
        print("decode person passwd:", decode.passwd)
        print("decode person     id:", decode.id)
    else
        print("proto decode error!!!!!!! typename:", typename2)
    end 
end

