TouchHelper = class("TouchHelper")
TouchHelper.__index = TouchHelper

function TouchHelper:add_touch_listener( obj, callback, filter_overflow, swallow)
	local func_begin  = callback[1]
	local func_end    = callback[2]
	local func_move   = callback[3]
	local func_cancel = callback[4]
	local filter_overflow = filter_overflow or false
	local swallow = swallow or false

	local function onTouchBegan(touch, event)
		if filter_overflow and TouchHelper.is_overflow_touch(touch, obj) then
			return false
		end

		if func_begin then
			return func_begin(touch, event)
		end

		-- CCTOUCHBEGAN event must return true
		-- 如果return false 后面的触摸事件都不会发生
		return true
	end

	local function onTouchMoved(touch, event)
		if func_move then
			func_move(touch, event)
		end
	end

	local function onTouchEnded(touch, event)
		if func_end then
			func_end(touch, event)
		end
	end

	local function onTouchCancelled(touch, event)
		if func_cancel then
			return func_cancel(touch, event)
		end
	end

	local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(swallow)
    listener:registerScriptHandler(onTouchBegan,	cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,	cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,	cc.Handler.EVENT_TOUCH_ENDED )
    listener:registerScriptHandler(onTouchCancelled,cc.Handler.EVENT_TOUCH_CANCELLED )

    local eventDispatcher = obj:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, obj)
end

-- 当前触摸是否是超出obj的范围的
function TouchHelper.is_overflow_touch(touch, obj)
	local touch_pos   = touch:getLocation()
    local local_pos   = obj:convertToNodeSpace(touch_pos)
    local parent_size = obj:getContentSize()

    if local_pos.x >= 0 and local_pos.x < parent_size.width and
       local_pos.y >= 0 and local_pos.y < parent_size.height
    then
        return false
    end

    return true
end