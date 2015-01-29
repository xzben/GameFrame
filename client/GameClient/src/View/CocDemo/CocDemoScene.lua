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
    self:addChild(bg_layer, 0)

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
    self.tilemap_obj_ = map
    bg_layer:addChild(map)

    local bg_size = cc.size(img_size.width*2, img_size.height)
    local min_x = visible_size.width/2 - (bg_size.width - visible_size.width)/2 
    local max_x = visible_size.width/2 + (bg_size.width - visible_size.width)/2
    local min_y = visible_size.height/2 - (bg_size.height - visible_size.height)/2 
    local max_y = visible_size.height/2 + (bg_size.height - visible_size.height)/2 

    local function onTouchBegan(touchs, event)
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
        else

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
            end
        else

        end
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

function CocDemoScene:init()
   self:add_bg_layer()
end

