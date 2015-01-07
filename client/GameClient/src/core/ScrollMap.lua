-------------------------------------------------------------------------------
-- @file ScrollMap.lua
--
--
-- 实现一个循环滚动的底图控件
-------------------------------------------------------------------------------

ScrollMap = ScrollMap or class("ScrollMap", EventDispatcher)

ScrollMapEvent = {
	EVT_SCROLL_DONE = 1,		--已经滚动到最后一个页面了
	EVT_CHANGE_MAIN_LAYER = 2, 	--切换主显示页面
}

--底图滚动方向
ScrollMapMoveDir = {
	LEFT 	= 1,
	RIGHT 	= 2,
	TOP 	= 3,
	BOTTOM 	= 4,
}

local scheduler = cc.Director:getInstance():getScheduler()
local SUB_MAP_TAG 		= 1 	--base_layer 上添加的显示底图的 tag
local BASE_LAYER_NUM 	= 3 	--默认添加的base_layer 的数量


--[[
	map_size 				地图的size
	create_page_iterator(index, layer_size)    地图创建子地图的迭代器函数,传递两个参数，当前创建的index，和要创建layer的size
	speed 			 		地图滚动的速度（每秒滚动多少个单位距离）
	move_dir 				地图的滚动方向(ScrollMapMoveDir)
--]]
function ScrollMap.create(map_size, create_page_iterator, speed, move_dir)
	return ScrollMap.extend(cc.Layer:create(), map_size, create_page_iterator, speed, move_dir)
end

function ScrollMap:ctor(map_size, create_page_iterator, speed, move_dir)
	self._create_page_iterator = create_page_iterator -- 创建显示的子地图的迭代器函数
	self._cur_create_index = 1  --当前创建子地图的index
	self._scroll_index 	= 1     --当前地图滚动的index
	self._speed = speed 		
	self._move_dir = move_dir
	self._loop_page_layer = {}
	self._is_start = false
	self._is_scroll_done = false
	self:setContentSize(map_size)

	local function handlercallback(event)
        if "enter" == event then
            self:on_enter()
        elseif "exit" == event then
            self:on_exit()
        end
    end
    self:registerScriptHandler(handlercallback)	
end

function ScrollMap:on_enter( )
	self:init()
end

function ScrollMap:on_exit( )
	if self.move_map_scheudler_ then
		scheduler:unscheduleScriptEntry( self.move_map_scheudler_ )
		self.move_map_scheudler_ = nil
	end
	self:destroy()
end

function ScrollMap:create_sub_map_add_to_base_layer( base_layer )
	base_layer:removeChildByTag(SUB_MAP_TAG)

	local map_size = self:getContentSize()
	local layer = self._create_page_iterator(self._cur_create_index, map_size)
	self._scroll_index = self._scroll_index + 1
	if not layer then return false end
	self._cur_create_index = self._cur_create_index + 1
	layer:ignoreAnchorPointForPosition(false)
	layer:setAnchorPoint(0, 0)
	layer:setPosition(0, 0)
	layer:setTag(SUB_MAP_TAG)
	base_layer:addChild(layer)

	return true
end

function ScrollMap:start()
	self._is_start = true
end

function ScrollMap:pause()
	self._is_start = false
end

function ScrollMap:set_speed( speed )
	self._speed = speed
end

function ScrollMap:get_cur_main_layer()
	local main_index = (self._scroll_index - BASE_LAYER_NUM)%(BASE_LAYER_NUM)
	if main_index == 0 then
		main_index = BASE_LAYER_NUM
	end
	
	--print("ScrollMap:get_cur_main_layer", main_index, self._scroll_index, BASE_LAYER_NUM)
	local main_base_layer = self._loop_page_layer[main_index]
	return main_base_layer, main_base_layer:getChildByTag(SUB_MAP_TAG)
end

function ScrollMap:init()
    local move_offset_map = {
    	[ScrollMapMoveDir.LEFT]		= { -1, 0},
    	[ScrollMapMoveDir.RIGHT]	= {  1, 0},
    	[ScrollMapMoveDir.TOP]		= {  0, 1},
    	[ScrollMapMoveDir.BOTTOM]	= {  0, -1},
	}
	local move_offset 		= move_offset_map[self._move_dir]
    local map_size 			= self:getContentSize()
	local limit_check_pos 	= cc.p(move_offset[1]*map_size.width, move_offset[2]*map_size.height)
	local end_pos 			= cc.p( (BASE_LAYER_NUM-1)*(map_size.width*-1*move_offset[1]), (BASE_LAYER_NUM-1)*(map_size.height*-1*move_offset[2]))

    --添加BASE_LAYER_NUM个循环滚动的layer
    for i = 1, BASE_LAYER_NUM, 1 do
    	local layer = cc.Layer:create()
    	layer:setContentSize(map_size)
    	layer:ignoreAnchorPointForPosition(false)
    	layer:setAnchorPoint(0, 0)
    	local init_x = (i-1)*(map_size.width*-1*move_offset[1])
    	local init_y = (i-1)*(map_size.height*-1*move_offset[2])
    	layer:setPosition( init_x, init_y)
    	self:create_sub_map_add_to_base_layer(layer)
    	self._loop_page_layer[i] = layer
    	self:addChild(layer)
    end

    local function check_is_up_to_limit( pos )
    	if move_offset[1] ~= 0 and move_offset[1]*pos.x >= move_offset[1]*limit_check_pos.x then
    		return true
    	end

    	if move_offset[2] ~= 0 and move_offset[2]*pos.y >= move_offset[2]*limit_check_pos.y then
    		return true
    	end

    	return false
    end

    local function update(dt)
    	if not self._is_start or self._is_scroll_done then return end

    	local move_length = self._speed * dt
    	local move_x = move_offset[1]*move_length
    	local move_y = move_offset[2]*move_length

    	for i = 1, BASE_LAYER_NUM, 1 do
    		local cur_layer = self._loop_page_layer[i]
    		local cur_pos = cc.p(cur_layer:getPosition())

    		local dest_pos = cc.p( cur_pos.x + move_x, cur_pos.y + move_y)
    		if check_is_up_to_limit(dest_pos) then --如果此layer已经滚动完毕则重新创建新layer替换，并添加到结尾位置
    			self:create_sub_map_add_to_base_layer(cur_layer)
    			dest_pos = cc.p(dest_pos.x - limit_check_pos.x + end_pos.x, dest_pos.y - limit_check_pos.y + end_pos.y)

    			self:dispatch_event(ScrollMapEvent.EVT_CHANGE_MAIN_LAYER, self:get_cur_main_layer())
    		end
    		cur_layer:setPosition(dest_pos)
    	end

    	if (self._scroll_index - self._cur_create_index) >= (BASE_LAYER_NUM-1) then
    		self._is_scroll_done = true
    		self:dispatch_event(ScrollMapEvent.EVT_SCROLL_DONE)
    	end
    end
    self.move_map_scheudler_ = scheduler:scheduleScriptFunc(update, 0.01, false)
end