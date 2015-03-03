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
    crab_obj = nil
    collectgarbage()

    ---[[
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
	--]]
    local visibleSize = VisibleRect:getVisibleSize()
    local texture = cc.Director:getInstance():getTextureCache():addImage("repeat.jpg")
    texture:setTexParameters(gl.LINEAR, gl.LINEAR, gl.REPEAT, gl.REPEAT)
    local sprite = cc.Sprite:createWithTexture(texture, cc.rect(0 , 0, visibleSize.width, visibleSize.height))
    sprite:setPosition(cc.p(visibleSize.width/2, visibleSize.height/2))
    self:addChild(sprite, 0)

    for i = 1, 4, 1 do
        for j = 1, 3, 1 do
            local card = self:create_card()
            card:setPosition(150*i, 200*j)
            self:addChild(card)
            card.run_action()
        end
    end
end

function PhysicsScene:create_card(  )
    local back = cc.Sprite:create("card/ui_card.png")
    local front = cc.Sprite:create("card/ui_card1.png")
    local card_size = front:getContentSize()
    local card = cc.Layer:create()
    card:setContentSize(card_size)
    front:setPosition(card_size.width/2, card_size.height/2)
    back:setPosition(card_size.width/2, card_size.height/2)
    front:setVisible(false)
    card:addChild(front)
    card:addChild(back)

    card.run_action =  function()
        local duration = 1.5
        front:stopAllActions()
        back:stopAllActions()
        --正面z轴起始角度为90度（向左旋转90度），然后向右旋转90度
        local orbitFront = cc.OrbitCamera:create(duration*0.5,1,0,90,-90,0,0);
        orbitFront:setTarget(front)
        orbitFront:setCenter({100,100,0})
        --正面z轴起始角度为0度，然后向右旋转90度
        local orbitBack = cc.OrbitCamera:create(duration*0.5,1,0,0,-90,0,0);
        orbitBack:setTarget(back)
        orbitBack:setCenter({100,100,0})
        front:setVisible(false)
        
        local function callback()
            local temp = front
            front = back
            back = temp
        end
        --背面向右旋转90度->正面向左旋转90度
        back:runAction(cc.RepeatForever:create( cc.Sequence:create(cc.TargetedAction:create(front, cc.Hide:create()),cc.Show:create(),orbitBack,cc.Hide:create(),
            cc.TargetedAction:create(front,cc.Sequence:create(cc.Show:create(),orbitFront)), cc.CallFunc:create(callback))))
    end

    card:ignoreAnchorPointForPosition(false)
    card:setAnchorPoint(0.5, 0.5)

    return card
end
