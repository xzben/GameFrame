-------------------------------------------------------------------------------
-- @file GameScene.lua 
--
--
-- 游戏初始加载场景
--
-------------------------------------------------------------------------------
GameScene = GameScene or class("GameScene", VBase)

function GameScene.create()
	return GameScene.extend(cc.Scene:create())
end

function GameScene:ctor()

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
    hero:run()
    hero:init_physics()
    print(hero:getContentSize().width, hero:getContentSize().height)
    
    
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

function GameScene:init()
    cc.Director:getInstance():getRunningScene():getPhysicsWorld():setGravity(cc.p(0, -980));
    cc.Director:getInstance():getRunningScene():getPhysicsWorld():setDebugDrawMask(cc.PhysicsWorld.DEBUGDRAW_ALL)

    local visible_size = VisibleRect:getVisibleSize()

    local function far_page_iterator(index, map_size)
        local spTmp = cc.Sprite:create("far-bg.png")
        return spTmp
    end
    local spTmp = cc.Sprite:create("far-bg.png")
    local far_map = ScrollMap.create(spTmp:getContentSize(), far_page_iterator, 200, ScrollMapMoveDir.LEFT)
    far_map:ignoreAnchorPointForPosition(false)
    far_map:setAnchorPoint(0.5, 0.5)
    far_map:setPosition(visible_size.width/2, visible_size.height/2);
    self:addChild(far_map, 1)
    far_map:start()

    local function near_page_iterator(index, map_size)
        local spTmp = cc.Sprite:create("near-bg.png")
        return spTmp
    end
    local spTmp = cc.Sprite:create("near-bg.png")
    local near_map = ScrollMap.create(spTmp:getContentSize(), near_page_iterator, 100, ScrollMapMoveDir.LEFT)
    near_map:ignoreAnchorPointForPosition(false)
    near_map:setAnchorPoint(0.5, 0)
    near_map:setPosition(visible_size.width/2, 0);
    self:addChild(near_map, 20)
    near_map:start()

    
    self:init_show_layer()
end

