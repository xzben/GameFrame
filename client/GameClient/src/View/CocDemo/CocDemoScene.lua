-------------------------------------------------------------------------------
-- @file CocDemoScene.lua 
--
--
-- 游戏主场景
--
-------------------------------------------------------------------------------

CocDemoScene = CocDemoScene or class("CocDemoScene", EventDispatcher)

function CocDemoScene.create()
	return CocDemoScene.extend(cc.Scene:create())
end

function CocDemoScene:ctor()

	local function handlercallback(event)
        if "enter" == event then
            self:on_enter()
        elseif "exit" == event then
            self:on_exit()
        end
    end
    self:registerScriptHandler(handlercallback)	
end

function CocDemoScene:on_enter( )
	self:init()
end

function CocDemoScene:on_exit( )
	self:destroy()
end

function CocDemoScene:add_bg_layer()
    local visible_size = VisibleRect:getVisibleSize()
    local bg_layer = cc.Layer:create()
    bg_layer:setContentSize(visible_size)
    bg_layer:ignoreAnchorPointForPosition(false)
    bg_layer:setAnchorPoint(0.5, 0.5)
    bg_layer:setPosition(VisibleRect:center())
    self:addChild(bg_layer)

    local bg_file = "coc/background_player/0.0.png"
    local left_bg = cc.Sprite:create(bg_file)
    left_bg:setScaleX(-1)
    local img_size = left_bg:getContentSize()
    left_bg:setPosition(visible_size.width/2-img_size.width/2, visible_size.height/2)
    local right_bg = cc.Sprite:create(bg_file)
    right_bg:setPosition(visible_size.width/2+img_size.width/2, visible_size.height/2)
    bg_layer:addChild(left_bg)
    bg_layer:addChild(right_bg)

    local map = ccexp.TMXTiledMap:create("coc/map_0_1.tmx")
    map:ignoreAnchorPointForPosition(false)
    map:setAnchorPoint(0.5, 0.5)
    map:setPosition(visible_size.width/2, visible_size.height/2+42*2)
    self._tilemap_obj = map
    bg_layer:addChild(map)

    local bg_size = cc.size(img_size.width*2, img_size.height)
    local min_x = visible_size.width/2 - (bg_size.width - visible_size.width)/2 
    local max_x = visible_size.width/2 + (bg_size.width - visible_size.width)/2
    local min_y = visible_size.height/2 - (bg_size.height - visible_size.height)/2 
    local max_y = visible_size.height/2 + (bg_size.height - visible_size.height)/2 
    local touch_begin_points = {}

    local function onTouchBegan(touchs, event)
        local touch_num = #touchs
        for index, touch in ipairs(touchs) do
            touch_begin_points[index] = touch:getLocation()
        end
        return true
    end

    local function onTouchMoved(touchs, event)
        local touch_num = #touchs
        if touch_num == 1 then --单点触摸则为移动背景
            local touch = touchs[1]
            local move_offset = touch:getDelta()
            local old_pos = cc.p(bg_layer:getPosition())
            local new_pos = cc.pAdd(old_pos, move_offset)
            if new_pos.x >= min_x and new_pos.x <= max_x and new_pos.y >= min_y and new_pos.y <= max_y then 
                bg_layer:setPosition(new_pos)
            end
        elseif touch_num >= 2 then
            if #touch_begin_points < 2 then
                touch_begin_points[1] = touchs[1]:getLocation()
                touch_begin_points[2] = touchs[2]:getLocation()
            else
                local move_points = {}
                move_points[1] = touchs[1]:getLocation()
                move_points[2] = touchs[2]:getLocation()

                local begin_len = cc.pGetLength(cc.pSub(touch_begin_points[1], touch_begin_points[2]))
                local end_len = cc.pGetLength(cc.pSub(move_points[1], move_points[2]))
                local offset = end_len - begin_len
                local cur_scale = bg_layer:getScale()
                local set_scale = cur_scale + offset/20*0.1
                print("#################### setScale 1: ", set_scale)
                set_scale = math.min(1, set_scale)
                set_scale = math.max(0.1, set_scale)

                bg_layer:setScale(set_scale)
                print("#################### setScale 2: ", set_scale)
                touch_begin_points = move_points
            end
        end
    end

    local function onTouchEnded(touchs, event)
        local touch_num = #touchs
        if touch_num == 1 then
            local touch = touchs[1]
            local touch_pos = touch:getLocation()
            local start_pos = touch:getStartLocation()
            local move_offset = cc.pSub(touch_pos, start_pos)
            if math.abs(move_offset.x) < 2 and math.abs(move_offset.y) < 2 then
                local local_pos = map:convertToNodeSpace(touch_pos)
                local map_pos, map_pos_1 = TileMapHelper.get_tile_pos_from_location(map, local_pos)
                print("map_pos:", map_pos.x, map_pos.y, "## ", map_pos_1.x, map_pos_1.y, touch_pos.x, touch_pos.y, local_pos.x, local_pos.y)
                self:move_roles_to(map_pos)
            end
        elseif touch_num >= 2 then
            
        end
        touch_begin_points = {}
    end
    
    TouchHelper:add_mutile_touch_listener( bg_layer, {onTouchBegan, onTouchEnded, onTouchMoved})
end

function CocDemoScene:add_ui_layer()
    local visible_size = VisibleRect:getVisibleSize()
    local ui_layer = cc.Layer:create()
    ui_layer:setContentSize(visible_size)
    ui_layer:ignoreAnchorPointForPosition(false)
    ui_layer:setAnchorPoint(0.5, 0.5)
    ui_layer:setPosition(VisibleRect:center())
    self:addChild(ui_layer, 0)

    local btn_build = ccui.Button:create()
end

function CocDemoScene:load_map_data()
    local all_map_data = require("View.CocDemo.map_0_1")
    local map_width = nil
    local map_height = nil
    local map_data = nil
    for _, layer_data in pairs(all_map_data.layers) do
        if layer_data.type == "tilelayer" and layer_data.name == "items" then
            map_width = layer_data.width
            map_height = layer_data.height
            map_data = layer_data.data
            break
        end 
    end
    assert(map_data ~= nil, "load map_data failed!!!!!!")
    local function check_is_block( point_data )
        return point_data ~= 0
    end
    self._find_path_helper = PathFindHelper.new(map_data, map_width, map_height, check_is_block)
end

function CocDemoScene:add_role_to_map( role, x, y)
    local layer = self._tilemap_obj:getLayer("items")
    role:init(layer, self._find_path_helper, cc.p(x, y))
    if not self._added_roles then
        self._added_roles = {}
    end
    table.insert(self._added_roles, role)
end

function CocDemoScene:move_roles_to( point )
    for _, role in pairs(self._added_roles) do
        role:move_to(point)
    end
end

function CocDemoScene:add_main_ui()
    local layer = CocMainUI.create()
    layer:ignoreAnchorPointForPosition(false)
    layer:setAnchorPoint(0.5, 0.5)
    layer:setPosition(VisibleRect:center())
    self:addChild(layer)
end

function CocDemoScene:init()
   self:add_bg_layer()
   self:add_main_ui()
   self:load_map_data()

   self:add_role_to_map( BaseRole.create("coc/characters/32.0.png"), 10, 10 )
end

