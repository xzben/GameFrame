-------------------------------------------------------------------------------
-- @file GameMapScene.lua 
--
--
-- 游戏主场景
--
-------------------------------------------------------------------------------

GameMapScene = GameMapScene or class("GameMapScene", EventDispatcher)


function GameMapScene.create()
	return GameMapScene.extend(cc.Scene:create())
end

function GameMapScene:ctor()

	
	local function handlercallback(event)
        if "enter" == event then
            self:on_enter()
        elseif "exit" == event then
            self:on_exit()
        end
    end
    self:registerScriptHandler(handlercallback)	
end

function GameMapScene:on_enter( )
	self:init()
end

function GameMapScene:on_exit( )
	self:destroy()
end

function GameMapScene:handle_change_main_sub_map(sender, base_layer, sub_map)
    if sub_map then
        print("handle_change_main_sub_map: ", sub_map:getName())
    end
end

function GameMapScene:handle_map_scroll_done(sender)
    print("GameMapScene:handle_map_scroll_done")
end

function GameMapScene:init()
    self:test_search_path()
    self:test_scroll_map()
    self:test_tilemap()
    self:test_tilemap_45()
end

function GameMapScene:test_scroll_map()
     local create_page_iterator = function(index, layer_size)
        if index > 10 then return nil end
        local layer = cc.LayerColor:create(cc.c4b(math.random(0, 255), math.random(0, 255), math.random(0, 255), 200))
        layer:setName(tostring(index))
        layer:setContentSize(layer_size)

        return layer
    end

    local visible_size = VisibleRect:getVisibleSize()
    local map_size = cc.size(visible_size.width*0.4, visible_size.height*0.4)
    local map_parent = ccui.Layout:create()
    map_parent:setContentSize(map_size)
    map_parent:ignoreAnchorPointForPosition(false)
    map_parent:setAnchorPoint(0.5, 0.5)
    map_parent:setPosition(visible_size.width/4, visible_size.height/4)
    map_parent:setClippingEnabled(true)
    self:addChild(map_parent)

    local scroll_map = ScrollMap.create(map_size, create_page_iterator, 100, ScrollMapMoveDir.LEFT)
    scroll_map:ignoreAnchorPointForPosition(false)
    scroll_map:setAnchorPoint(0.5, 0.5)
    scroll_map:setPosition(map_size.width/2, map_size.height/2)
    map_parent:addChild(scroll_map)
    scroll_map:add_listener(ScrollMapEvent.EVT_CHANGE_MAIN_LAYER, self.handle_change_main_sub_map, self)
    scroll_map:add_listener(ScrollMapEvent.EVT_SCROLL_DONE, self.handle_map_scroll_done, self)

    scroll_map:start()
end

function GameMapScene:test_search_path()
    local map = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 1, 1, 1, 1, 1, 1, 1, 1, 0,
        0, 1, 0, 0, 0, 1, 1, 1, 1, 0,
        0, 1, 1, 1, 0, 1, 1, 1, 1, 0,
        0, 1, 1, 1, 0, 1, 1, 1, 1, 0,
        0, 1, 1, 1, 0, 1, 1, 1, 1, 0,
        0, 1, 0, 0, 0, 1, 1, 1, 1, 0,
        0, 1, 0, 0, 0, 1, 1, 1, 1, 0,
        0, 1, 1, 1, 1, 1, 1, 1, 1, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    }

    local pathHelper = PathFindHelper.new(map, 10, 10)
    -- 不允许走斜线的路径
    local path = pathHelper:find_path(cc.p(4, 5), cc.p(9, 5), true) or {}
    for _, item in pairs(path) do
        print(string.format("(%d,%d)", item.x, item.y))
    end

    -- 允许走斜线的路径
    local path = pathHelper:find_path(cc.p(4, 5), cc.p(9, 5), false) or {}
    for _, item in pairs(path) do
        print(string.format("(%d,%d)", item.x, item.y))
    end
end

function GameMapScene:test_tilemap()
    local parent_layer = cc.Layer:create()
    local layer_size = VisibleRect:getVisibleSize()
    layer_size = cc.size(layer_size.width*0.5, layer_size.height*0.5)
    parent_layer:setContentSize(layer_size)
    parent_layer:setPosition(layer_size.width, 0)
    self:addChild(parent_layer)
    local map = ccexp.TMXTiledMap:create("TileMap/TestTileMap.tmx")
    map:setScale(0.5)
    parent_layer:addChild(map)

    local function touch_began(touch, event)
        return true
    end

    local function touch_end(touch, event)
        local touch_pos = touch:getLocation()
        local local_pos  = parent_layer:convertToNodeSpace(touch_pos)

        local map_pos = TileMapHelper.get_tile_pos_from_location(map, local_pos)
        local layer = map:getLayer("layer")
        local real_pos = cc.p( layer:getPositionAt(map_pos) )
        print("touch pos", map_pos.x, map_pos.y, local_pos.x, local_pos.y, real_pos.x, real_pos.y)
        local tile = layer:getTileAt(map_pos)
        if tile then
            tile:removeFromParent()
        end
    end
    TouchHelper:add_touch_listener(parent_layer, { touch_began, touch_end }, true)
end

function GameMapScene:test_tilemap_45()
    local parent_layer = cc.Layer:create()
    local layer_size = VisibleRect:getVisibleSize()
    layer_size = cc.size(layer_size.width*0.5, layer_size.height*0.5)
    parent_layer:setContentSize(layer_size)
    parent_layer:setPosition(0, layer_size.height)
    self:addChild(parent_layer)
    local map = ccexp.TMXTiledMap:create("TileMap/Test45TileMap.tmx")
    map:setScale(0.5)
    parent_layer:addChild(map)

    local function touch_began(touch, event)
        return true
    end

    local function touch_end(touch, event)
        local touch_pos = touch:getLocation()
        local local_pos  = parent_layer:convertToNodeSpace(touch_pos)

        local map_pos = TileMapHelper.get_tile_pos_from_location(map, local_pos)
        local layer = map:getLayer("layer")
        local real_pos = cc.p( layer:getPositionAt(map_pos) )
        print("touch pos", map_pos.x, map_pos.y, local_pos.x, local_pos.y, real_pos.x, real_pos.y)
        local tile = layer:getTileAt(map_pos)
        if tile then
            tile:removeFromParent()
        end
    end
    TouchHelper:add_touch_listener(parent_layer, {touch_began, touch_end}, true)
end