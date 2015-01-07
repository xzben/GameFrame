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
    local create_page_iterator = function(index, layer_size)
        if index > 10 then return nil end
        local layer = cc.LayerColor:create(cc.c4b(255/index, 255/index, 255/index, 200))
        layer:setName(tostring(index))
        layer:setContentSize(layer_size)

        return layer
    end

    local visible_size = VisibleRect:getVisibleSize()
    local map_size = cc.size(visible_size.width*0.8, visible_size.height*0.8)
    local map_parent = ccui.Layout:create()
    map_parent:setContentSize(map_size)
    map_parent:ignoreAnchorPointForPosition(false)
    map_parent:setAnchorPoint(0.5, 0.5)
    map_parent:setPosition(visible_size.width/2, visible_size.height/2)
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