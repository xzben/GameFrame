-------------------------------------------------------------------------------
-- @file GameScene.lua 
--
--
-- 游戏初始加载场景
--
-------------------------------------------------------------------------------
GameScene = GameScene or class("GameScene", VBase)

local far_speed_scale = 0.8
local near_speed_scale = 1
local way_speed_scale = 1

local hero_bitmask = 1          -- 0001
local hero_collision_bitmask =  2
local hero_contact_bitmask = 255

local platform_bitmask = 2      -- 0010
local platform_collision_bitmask = 255 
local platfrom_contact_bitmask = 255


local gold_bitmask = 4          -- 0100
local gold_collision_bitmask = 1
local gold_contact_bitmask = 255

function GameScene.create()
	return GameScene.extend(cc.Scene:create())
end

function GameScene:ctor()
    self._baseSpeed = 200
    self._hero = nil
    self._farBg = nil
    self._nearBg = nil
    self._way = nil

end

function GameScene:on_enter( )
	self:init()
end

function GameScene:on_exit( )
    cc.Director:getInstance():getRunningScene():getPhysicsWorld():setGravity(cc.p(0, 0));
end

function GameScene:onBtnback()
    GSession:lauchScene()
end

function GameScene:init_show_layer()
    local visible_size = VisibleRect:getVisibleSize()
    local show_layer = cc.Layer:create()
    show_layer:ignoreAnchorPointForPosition(false)
    show_layer:setAnchorPoint(0.5, 0.5)
    show_layer:setPosition(VisibleRect:center())
    show_layer:setContentSize(visible_size)
    self:addChild(show_layer, 30)

    local btnExt = ccui.Button:create("ui/back-btn.png")
    btnExt:ignoreAnchorPointForPosition(false)
    btnExt:setAnchorPoint(0, 1)
    btnExt:setPosition(cc.p(10, visible_size.height-10))
    local function touchEvent(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            self:onBtnback()
        end
    end  
    btnExt:addTouchEventListener(touchEvent)
    show_layer:addChild(btnExt)

    local wall = cc.Node:create()
    wall:setPhysicsBody(cc.PhysicsBody:createEdgeBox(VisibleRect:getVisibleSize(), cc.PhysicsMaterial(0.1, 1, 0.0), 5))
    wall:setPosition(VisibleRect:center())
    show_layer:addChild(wall, 1000)

    local hero = Hero.create()
    show_layer:addChild(hero)
    hero:ignoreAnchorPointForPosition(false)
    hero:setAnchorPoint(0.5, 0.5)
    hero:setPosition(cc.p(visible_size.width/2, 400))
    hero:init_physics();
    hero:getPhysicsBody():setCategoryBitmask(hero_bitmask)
    hero:getPhysicsBody():setContactTestBitmask(hero_contact_bitmask)
    hero:getPhysicsBody():setCollisionBitmask(hero_collision_bitmask)
    
    hero:add_listener("updateSpeed", self.handleHeroSpeedUpdate, self)

    self._hero = hero

    local function onTouchBegan(touch, event)
        print("jump .....")
        hero:jump()
        return true
    end
    
    local function onTouchEnded(touch, event)
       
    end

    local function onTouchMoved(touch, event)
       
    end

    local function onTouchCancelled(touch, event)
        
    end
    TouchHelper:add_touch_listener( show_layer, {onTouchBegan, onTouchEnded, onTouchMoved, onTouchCancelled})
    
    return show_layer
end

function GameScene:setSpeed(speed)
    local visible_size = VisibleRect:getVisibleSize()
    self._farBg:set_speed(speed*far_speed_scale)
    self._nearBg:set_speed(speed*near_speed_scale)
    self._way:set_speed(speed*way_speed_scale)
end

function GameScene:handleHeroSpeedUpdate(sender, vel)
    self:setSpeed(self._baseSpeed+vel.x)
end

function GameScene:init()
    cc.Director:getInstance():getRunningScene():getPhysicsWorld():setGravity(cc.p(0, -980));
    --cc.Director:getInstance():getRunningScene():getPhysicsWorld():setDebugDrawMask(cc.PhysicsWorld.DEBUGDRAW_ALL)

    local visible_size = VisibleRect:getVisibleSize()
    self:loadFrame("platform")
    self:loadAnimateByFrames("gold", "gold%d.png", 0, 9, 0.08)
    
    local function far_page_iterator(index, map_size)
        local spTmp = cc.Sprite:create("far-bg.png")
        return spTmp
    end
    local spTmp = cc.Sprite:create("far-bg.png")
    local far_map = ScrollMap.create(spTmp:getContentSize(), far_page_iterator, self._baseSpeed*far_speed_scale, ScrollMapMoveDir.LEFT)
    far_map:ignoreAnchorPointForPosition(false)
    far_map:setAnchorPoint(0.5, 0.5)
    far_map:setPosition(visible_size.width/2, visible_size.height/2);
    self:addChild(far_map, 1)
    self._farBg = far_map
    far_map:start()

    local function near_page_iterator(index, map_size)
        local spTmp = cc.Sprite:create("near-bg.png")
        return spTmp
    end
    local spTmp = cc.Sprite:create("near-bg.png")
    local near_map = ScrollMap.create(spTmp:getContentSize(), near_page_iterator, self._baseSpeed*near_speed_scale, ScrollMapMoveDir.LEFT)
    near_map:ignoreAnchorPointForPosition(false)
    near_map:setAnchorPoint(0.5, 0)
    near_map:setPosition(visible_size.width/2, 0);
    self:addChild(near_map, 20)
    near_map:start()
    self._nearBg = near_map

    local function create_gold()
        local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("gold0.png")
        local spGold = cc.Sprite:createWithSpriteFrame(frame)
        spGold:runAction(cc.RepeatForever:create( self:animate("gold%d.png")) )
        spGold:ignoreAnchorPointForPosition(false)
        spGold:setAnchorPoint(0.5, 0.5)
        local body = cc.PhysicsBody:createBox(spGold:getContentSize(), cc.PhysicsMaterial(0, 0, 0.0))
        body:setDynamic(false)
        body:setCategoryBitmask(gold_bitmask)
        body:setContactTestBitmask(gold_contact_bitmask)
        body:setCollisionBitmask(gold_collision_bitmask)

        spGold:setPhysicsBody(body)
        
        return spGold
    end

    local function create_platform( index )
        local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format("platform_%d.png", index))
        local sp = cc.Sprite:createWithSpriteFrame(frame)
        local body = cc.PhysicsBody:createBox(sp:getContentSize(), cc.PhysicsMaterial(0, 0, 0.0))
        body:setDynamic(false)
        body:setCategoryBitmask(platform_bitmask)
        body:setContactTestBitmask(platfrom_contact_bitmask)
        body:setCollisionBitmask(platform_collision_bitmask)
        sp:setPhysicsBody(body)

        
        local gold = create_gold()
        gold:setPosition(10, 120)
        sp:addChild(gold)

        return sp
    end


    local function way_page_iterator(index, map_size)
        local way = cc.Layer:create()

        local platform = create_platform(4)
        platform:ignoreAnchorPointForPosition(false)
        platform:setAnchorPoint(0.5, 0.5)
        platform:setPosition(map_size.width/2, platform:getContentSize().height/2)
        way:addChild(platform)

        local platfrom1 = create_platform(2)
        platfrom1:ignoreAnchorPointForPosition(false)
        platfrom1:setAnchorPoint(0.5, 0.5)
        platfrom1:setPosition(map_size.width/2, platform:getContentSize().height/2+200)
        way:addChild(platfrom1)

        way:setContentSize(map_size)
        return way
    end

    local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("platform_4.png")
    local sp = cc.Sprite:createWithSpriteFrame(frame)

    local way_map = ScrollMap.create(cc.size(sp:getContentSize().width, visible_size.height), way_page_iterator, self._baseSpeed*way_speed_scale, ScrollMapMoveDir.LEFT)
    way_map:ignoreAnchorPointForPosition(false)
    way_map:setAnchorPoint(0.5, 0)
    way_map:setPosition(visible_size.width/2, 0);
    self:addChild(way_map, 20)
    way_map:start()
    self._way = way_map
    
    self:init_show_layer()

    local function onContactBegin(contact)
        local a = contact:getShapeA():getBody();
        local b = contact:getShapeB():getBody();
        local gold = nil

        if a:getCategoryBitmask() == gold_bitmask then
            gold = a
        end
        
        if b:getCategoryBitmask() == gold_bitmask then
            gold = b
        end
        
        if gold then
            gold:getNode():removeFromParent();
        end

        print("onContactBegin", a:getCategoryBitmask(), b:getCategoryBitmask())
        return true;
    end

    local function onContactSeperate( contact )
        local a = contact:getShapeA():getBody();
        local b = contact:getShapeB():getBody();


        print("onContactSeperate", a:getCategoryBitmask(), b:getCategoryBitmask())
        return true;
    end

    local contactListener = cc.EventListenerPhysicsContact:create();
    contactListener:registerScriptHandler(onContactBegin, cc.Handler.EVENT_PHYSICS_CONTACT_BEGIN);
    contactListener:registerScriptHandler(onContactSeperate, cc.Handler.EVENT_PHYSICS_CONTACT_SEPERATE);

    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(contactListener, self);
end
