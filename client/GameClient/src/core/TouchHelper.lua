TouchHelper = class("TouchHelper")
TouchHelper.__index = TouchHelper

function TouchHelper:add_touch_listener( obj, func_begin, func_end, func_move, func_cancel)

	local function onTouchBegan(touch, event)
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
    
    listener:registerScriptHandler(onTouchBegan,	cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,	cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,	cc.Handler.EVENT_TOUCH_ENDED )
    listener:registerScriptHandler(onTouchCancelled,cc.Handler.EVENT_TOUCH_CANCELLED )

    local eventDispatcher = obj:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, obj)
end