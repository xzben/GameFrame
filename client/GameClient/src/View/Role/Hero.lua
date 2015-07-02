-------------------------------------------------------------------------------
-- @file Hero.lua 
--
--
-- 角色
--
-------------------------------------------------------------------------------

Hero = Hero or class("Hero", VBase)
local scheduler = cc.Director:getInstance():getScheduler()

function Hero.create()
	return Hero.extend(cc.Sprite:create())
end

function Hero:ctor()
	self._FSM = FiniteStateMachine.new()
    self._update_scheduler = nil
end

function Hero:on_enter()
	self:init()
end

function Hero:on_exit()
    self:clear_scheduler();
end

function Hero:run()
	self._FSM:do_event("run")
end

function Hero:jump()
    self:getPhysicsBody():applyImpulse(cc.p(0, 1000))
    self._FSM:do_event("jump")
end

function Hero:roll()
	self._FSM:do_event("roll")
end

function Hero:clear_scheduler()
    if self._update_scheduler then
        scheduler:unscheduleScriptEntry( self._update_scheduler )
        self._update_scheduler = nil
    end
end

function Hero:update(dt)
   local v = self:getPhysicsBody():getVelocity()

end

function Hero:init_physics()
    self:setPhysicsBody(cc.PhysicsBody:createBox(cc.size(50, 50)))
    self:clear_scheduler();
    local function update(dt)
        self:update(dt)
    end
    self._update_scheduler = scheduler:scheduleScriptFunc(update, 0.01, false)
end

function Hero:init()
	self:loadAnimateByFrames("panda", "panda_run_%02d.png", 1, 8, 0.08)
	self:loadAnimateByFrames("panda", "panda_jump_%02d.png", 1, 8, 0.08)
	self:loadAnimateByFrames("panda", "panda_roll_%02d.png", 1, 8, 0.08)

    self:setContentSize(self:animation("panda_run_%02d.png"))
	
    local stateActionTag = 999
	local fsm_init_tbl = {
    	init_state = "running",
        states = {
            ["running"]    = { enter = function (fsm, to_state, from_state, event_name)
                                        print("####### event_name ###", event_name, "from_state ", from_state, " to_state ", to_state, "####################################") 
                                        local animate = self:animate("panda_run_%02d.png")
                                        self:stopActionByTag(stateActionTag)
                                        local action = cc.RepeatForever:create(animate)
                                        action:setTag(stateActionTag)
                                        self:runAction(action)
                                    end, leave = nil },
            ["jumping"] = { enter = function (fsm, to_state, from_state, event_name) 
                                        print("####### event_name ###", event_name, "from_state ", from_state, " to_state ", to_state, "####################################")
                                        local animate = self:animate("panda_jump_%02d.png")
                                        self:stopActionByTag(stateActionTag)
                                        local action = cc.RepeatForever:create(animate)
                                        action:setTag(stateActionTag)
                                        self:runAction(action)
                                    end, leave = nil },

            ["rolling"]  = { enter = function (fsm, to_state, from_state, event_name) 
                                        print("####### event_name ###", event_name, "from_state ", from_state, " to_state ", to_state, "####################################") 
                                        local animate = self:animate("panda_roll_%02d.png")
                                        self:stopActionByTag(stateActionTag)
                                        local action = cc.RepeatForever:create(animate)
                                        action:setTag(stateActionTag)
                                        self:runAction(action)
                                    end, leave = nil },
        },

        events = {
            ["run"]   = { from = {"rolling", "jumping" },  to = "running" },
            ["jump"]  = { from = {"running", "rolling" },  to = "jumping" },
            ["roll"]  = { from = {"jumping", "running" },  to = "rolling" },
        }
    }

    self._FSM:init(fsm_init_tbl)
end

