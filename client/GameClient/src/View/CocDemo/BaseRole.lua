-------------------------------------------------------------------------------
-- @file BaseRole.lua 
--
--
-- 角色
--
-------------------------------------------------------------------------------
BaseRole = BaseRole or class("BaseRole", EventDispatcher)
local sprite_frame_cache = cc.SpriteFrameCache:getInstance()

function BaseRole.create(init_filename)
	return BaseRole.extend(cc.Sprite:create(init_filename))
end

function BaseRole:ctor( start_index, end_index)
	self._fsm = FiniteStateMachine.new()
	self._file_start_index = start_index
	self._file_end_index = end_index


	self:setAnchorPoint(0, 0)
	local function handlercallback(event)
        if "enter" == event then
            self:on_enter()
        elseif "exit" == event then
            self:on_exit()
        end
    end
    self:registerScriptHandler(handlercallback)	
end

function BaseRole:on_enter( )

end

function BaseRole:on_exit()
	self:destroy()
end

function BaseRole:move_to( map_point )
	local begin_time = os.time()
	print("################ begin find path  ##############################")
	local path = self._find_path_helper:find_path(self._cur_point, map_point)
	print("################ end find path  ##############################", os.time() - begin_time)
	if not path or #path < 1 then
		return
	end
	local move_path_index = 1

	self:stopActionByTag(1)
	local function move_step()
		local point = path[move_path_index]
		if not point then return end
		self._cur_point = point
		move_path_index = move_path_index + 1
		local pos = self._map_layer:getPositionAt(point)
		local action = cc.Sequence:create(cc.MoveTo:create(0.1, pos), cc.CallFunc:create(move_step))
		action:setTag(1)
		self:runAction(action)
	end
	move_step()
end

function BaseRole:init(map_layer, find_path_helper, init_point)
	self._map_layer = map_layer
	self._cur_point = init_point
	self._find_path_helper = find_path_helper

	local pos = map_layer:getPositionAt(init_point)
    self:setPosition(pos)
    map_layer:addChild(self)

    
end

