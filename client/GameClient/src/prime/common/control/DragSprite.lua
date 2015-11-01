-------------------------------------------------------------------------------
-- @file DragSprite.lua 
--
--
-- 实现拖拽的精灵
--
-------------------------------------------------------------------------------
local DragSprite = class("DragSprite", core.EventDispatcher)

DragSpriteEvent = {
	DRAGE_BEGIN				= 1,		-- 通知目标已经开始移动
	DRAG_ON_TARGET 			= 2,		-- 已经移动到目标的范围内
	DRAG_LEAVE_TARGET 		= 3,		-- 已经移动一开范围
	DRAG_DONE_OUT_TRAGET	= 4,		-- 已经完成移动
	DRAG_DONE_ON_TARGET 	= 5, 		-- 完成移动，并且当时还在目标上
}

function DragSprite.create(img_path, target, event_target, event_data, size, is_imageview)
	local retSprite = DragSprite.extend(cc.Sprite:create(img_path), target, event_target, event_data, size, is_imageview)
	return retSprite
end

-- target 		拖拽的图形目标，拖拽的目标容器
-- event_target 拖拽事件的接受目标，必须是 EventDispatcher 的子类
function DragSprite:ctor(target, event_target, event_data, size, is_imageview)
	self.size_ = size
	self.target_ = target
	self.event_target_ = event_target
	self.event_data_ = event_data
	self.is_enable_ = true
	self.is_imageview_ = is_imageview

	self:setContentSize(size)
	self:init()

	local function handlercallback(event)
        if "enter" == event then
            self:on_enter()
        elseif "exit" == event then
            self:on_exit()
        end
    end
    self:registerScriptHandler(handlercallback)	
end

function DragSprite:on_enter( )
	
end

function DragSprite:on_exit( )
	--self:destroy()
end

function DragSprite:set_enable( is_enable )
	self.is_enable_ = is_enable
end

function DragSprite:is_enable( )
	return self.is_enable_
end

function DragSprite:notify_target( event, ... )
	if self.event_target_.dispatch_event then
		self:dispatch_event(event, self.event_data_, ...)
	else
		print("notify_target error")
	end
end

function DragSprite:copy()
	return cc.Sprite:createWithSpriteFrame(self:getSpriteFrame())
end

function DragSprite:init()
	local is_begin = false			-- 是否开始移动, move 和 end 都会将其设置为false
	local is_in_target = false		-- 是否移动到目标中
	local sprite_frame 
	local move_sprite

	local function onTouchBegan(touch, event)
		local touch_pos   = touch:getLocation()

		local function begin_move_call()
			if is_begin  and not move_sprite then
				move_sprite = self:copy()
				move_sprite:setScale(1.5)
				move_sprite:ignoreAnchorPointForPosition(false)
				move_sprite:setAnchorPoint(0.5, 0.5)

				local local_pos  = self:convertToNodeSpace(touch_pos)
				local world_pos = self:convertToWorldSpace(local_pos)
				--print(world_pos.x, world_pos.y)
				move_sprite:setPosition(world_pos.x, world_pos.y)
				cc.Director:getInstance():getRunningScene():addChild(move_sprite)
	
				self:notify_target(DragSpriteEvent.DRAGE_BEGIN) -- 通知目标开始移动
				AudioEngine.playEffect(propMusicSound[13].ResName)
			end
		end

		if self:is_enable() and not move_sprite then
			local cur_target = event:getCurrentTarget()
			--print("touch_pos x", touch_pos.x, "touch_pos y", touch_pos.y)
			local local_pos = cur_target:convertToNodeSpace(touch_pos)
			local scale = cur_target:getScale()
			local_pos.x = local_pos.x*scale
			local_pos.y = local_pos.y*scale
			local local_size = self:getContentSize()
			local_size.width = local_size.width*scale
			local_size.height = local_size.height*scale

			if local_pos.x >= 0 and local_pos.x < local_size.width and
			   local_pos.y >= 0 and local_pos.y < local_size.height
			then
				--print(local_pos.x, local_pos.y, local_size.width, local_size.height)
				is_begin = true
				self:run_delay(0.5, begin_move_call)
				return true -- 必不可少
			end
		end

		return false 
	end 
	
	local function onTouchCancel(touch,event)
		--print("DragSprite onTouchCancel ")
		is_begin = false
	end

	local function onTouchMoved(touch, event)
		local touch_pos  = touch:getLocation()

		local target_size = self.target_:getContentSize()
		local local_pos   = self:convertToNodeSpace(touch_pos)
		local target_pos  = self.target_:convertToNodeSpace(touch_pos)
		local self_size   = self:getContentSize()
		local is_in_self_rect = false

		-- 判断是否移动出自身范围，如果移动出自身范围则会取消延迟执行的拖拽动作
		--[[
		if is_begin and not (local_pos.x >= 0 and local_pos.x <= self_size.width and
		   					 local_pos.y >= 0 and local_pos.y <= self_size.height)
		then
			print("cancel the drag!!!!")
			is_begin = false
		end
		]]
		if  move_sprite then
			if target_pos.x >= 0 and target_pos.x < target_size.width and
			   target_pos.y >= 0 and target_pos.y < target_size.height
			then
				if not is_in_target then
					--print("DragSpriteEvent.DRAG_ON_TARGET")
					self:notify_target(DragSpriteEvent.DRAG_ON_TARGET)
				end
				is_in_target = true
			else
				if is_in_target then 
					--print("DragSpriteEvent.DRAG_LEAVE_TARGET")
					self:notify_target(DragSpriteEvent.DRAG_LEAVE_TARGET)
				end
				is_in_target = false
			end

			local local_pos  = self:convertToNodeSpace(touch_pos)
			local world_pos = self:convertToWorldSpace(local_pos)
			move_sprite:setPosition(world_pos.x, world_pos.y)

		end
		--print("onTouchMoved"..os.time())
	end

	local function end_clear_work()
		if move_sprite then
			move_sprite:removeFromParent()
		end

		move_sprite = nil
		sprite_frame = nil
		is_begin = false
		is_in_target = false
	end
	-- 拖拽结束时，未拖拽到目标上，则显示一个放回去的效果
	local function on_end_move_back()
		if move_sprite then 
			local self_size = self:getContentSize()
			local des_pos = cc.p(self_size.width/2, self_size.height/2)
			des_pos = self:convertToWorldSpace(des_pos)
			local action_move_to 		= cc.MoveTo:create(0.5, des_pos)

			function on_end()
				end_clear_work()
				self:notify_target(DragSpriteEvent.DRAG_DONE_OUT_TRAGET)  --通知目标移动结束了
			end

			local actionCallBack = cc.CallFunc:create(on_end)
			local actionSequene = cc.Sequence:create(action_move_to, actionCallBack)
			move_sprite:runAction(actionSequene)
		end
	end

	local function onTouchEnd(touch,event)
		local touch_pos   = touch:getLocation()
		--print("DragSprite ---- onTouchEnd")
		if move_sprite then
			local target_size = self.target_:getContentSize()
			local local_pos   = self:convertToNodeSpace(touch_pos)
			local target_pos  = self.target_:convertToNodeSpace(touch_pos)

			if target_pos.x >= 0 and target_pos.x < target_size.width and
			   target_pos.y >= 0 and target_pos.y < target_size.height
			then
				--print("DragSpriteEvent.DRAG_DONE_ON_TARGET")
				self:notify_target(DragSpriteEvent.DRAG_DONE_ON_TARGET)
				end_clear_work()
			else
				--print("DragSpriteEvent.DRAG_DONE_OUT_TRAGET")
				on_end_move_back()
			end
		else
			end_clear_work()
		end
	end
	
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(onTouchBegan,  cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(onTouchMoved,  cc.Handler.EVENT_TOUCH_MOVED)
	listener:registerScriptHandler(onTouchCancel, cc.Handler.EVENT_TOUCH_CANCELLED)
	listener:registerScriptHandler(onTouchEnd, 	  cc.Handler.EVENT_TOUCH_ENDED)

	local eventDispatcher = self:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

return DragSprite