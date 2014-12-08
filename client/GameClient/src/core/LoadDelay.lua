-------------------------------------------------------------------------------
-- @file LoadDelay.lua  
--
--
-- 提供延迟加载接口，在需要加载比较多控件的页面的时候通过分帧加载达到错峰效果
-- 
--
-------------------------------------------------------------------------------

LoadDelayEvent = {
    START   = 1,
    END     = 2,
}

LoadDelay = LoadDelay or class("LoadDelay", EventDispatcher)

function LoadDelay.create( load_func, ... )
    return LoadDelay.extend(cc.Node:create(), load_func, ...)
end

function LoadDelay:ctor( load_func, ... )
    if not load_func then
        return
    end

    self.load_func_ = load_func
    self.params_    = {...}
    self.delay_frame_num_ = 0
    self.finished_ = false
    self.pause_loading_ = false --是否暂停加载

    local function handlercallback(event)
        if "enter" == event then
            self:on_enter()
        elseif "exit" == event then
            self:on_exit()
        end
    end
    self:registerScriptHandler(handlercallback)
end

function LoadDelay:pause_load( )
    self.pause_loading_ = true
end

function LoadDelay:continue_load()
     self.pause_loading_ = false
end

function LoadDelay:on_enter( )
    self:init()
end

function LoadDelay:on_exit( )
    self:unscheduleUpdate()
    self.coroutine_ = nil
    self:destroy()
end

function LoadDelay:init( )
    local function func( )
        self:dispatch_event(LoadDelayEvent.START)
        self.load_func_(unpack(self.params_))
        self:dispatch_event(LoadDelayEvent.END)
        self:unscheduleUpdate()
    end
    self.coroutine_ = coroutine.create(func)
    
    local function update( deta )
        if self.coroutine_ and not self.pause_loading_ then
            self.delay_frame_num_ = self.delay_frame_num_ - 1
            if self.delay_frame_num_ <= 0 then 
                coroutine.resume(self.coroutine_)
            end
        end
    end
    self:scheduleUpdateWithPriorityLua(update, 0)  
end

function LoadDelay:delay(frame_num)
    self.delay_frame_num_ = frame_num or 1
    coroutine.yield()
end

function LoadDelay:set_finished( flag )
    self.finished_ = flag
end

function LoadDelay:is_finished( )
    return self.finished_
end