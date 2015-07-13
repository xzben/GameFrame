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
    local curStatus = self._FSM:getCurStatus()
    if curStatus == "jumping2" or curStatus == "rolling" then return end

    if curStatus == "jumping" then
        self._FSM:do_event("jump2")
    else
        self._FSM:do_event("jump")
    end
    self:getPhysicsBody():applyImpulse(cc.p(0, 400), cc.p(0,0))
    self.jumpTime = 0 
    
end

function Hero:clear_scheduler()
    if self._update_scheduler then
        scheduler:unscheduleScriptEntry( self._update_scheduler )
        self._update_scheduler = nil
    end
end

function Hero:update(dt)
    local vel = self:getPhysicsBody():getVelocity()
    local curStatus = self._FSM:getCurStatus()
    if not self.jumpTime then
        self.jumpTime = 0
    end
    self.jumpTime = self.jumpTime + dt
    local pos = cc.p(self:getPosition())
    --print("status:", curStatus, "time:",self.jumpTime, "vel:", vel.y, vel.x, "pos:", pos.y, pos.x)
    
    if vel.y < 0 and math.abs(vel.y) > 100 and curStatus ~= "downing" then
        self._FSM:do_event("down")
    end

    if curStatus == "jumping" or curStatus == "jumping2" then
        if math.abs(vel.y) < 10 then
            self._FSM:do_event("down")
        end
    elseif curStatus == "downing" then
        if vel.y > 0 then
            self._FSM:do_event("roll")
        end
    end
    self:setRotation(0)
    self:getPhysicsBody():setVelocity(cc.p(0, vel.y))
    self:dispatch_event("updateSpeed", vel)
end

function Hero:init_physics()
    local size = self:getContentSize()
    local body = cc.PhysicsBody:createBox(size,cc.PhysicsMaterial(0, 0, 0.0))
    print("moment:", body:getMoment())
    self:setPhysicsBody(body)
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
                                        local action = animate
                                        action:setTag(stateActionTag)
                                        self:runAction(action)
                                    end, leave = nil },
            ["jumping2"] = { enter = function (fsm, to_state, from_state, event_name) 
                                        print("####### event_name ###", event_name, "from_state ", from_state, " to_state ", to_state, "####################################")
                                        local animate = self:animate("panda_jump_%02d.png")
                                        self:stopActionByTag(stateActionTag)
                                        local action = animate
                                        action:setTag(stateActionTag)
                                        self:runAction(action)
                                    end, leave = nil },

            ["rolling"]  = { enter = function (fsm, to_state, from_state, event_name) 
                                        print("####### event_name ###", event_name, "from_state ", from_state, " to_state ", to_state, "####################################") 
                                        local animate = self:animate("panda_roll_%02d.png")
                                        self:stopActionByTag(stateActionTag)
                                        local function callback()
                                            self._FSM:do_event("run")
                                        end
                                        local action = cc.Sequence:create(animate, cc.CallFunc:create(callback))
                                        action:setTag(stateActionTag)
                                        self:runAction(action)
                                    end, leave = nil },
            ["downing"]  = { enter = function (fsm, to_state, from_state, event_name) 
                                        print("####### event_name ###", event_name, "from_state ", from_state, " to_state ", to_state, "####################################") 
                                        local animate = self:animate("panda_jump_%02d.png")
                                        self:stopActionByTag(stateActionTag)
                                        local action = animate
                                        action:setTag(stateActionTag)
                                        self:runAction(action)
                                    end, leave = nil },                
        },

        events = {
            ["run"]   = { from = {"rolling", "running", "jumping", "jumping2", "downing" },   to = "running" },
            ["jump"]  = { from = {"rolling", "running", "jumping", "jumping2", "downing" },   to = "jumping" },
            ["jump2"] = { from = {"rolling", "running", "jumping", "jumping2", "downing" },   to = "jumping2"},
            ["roll"]  = { from = {"rolling", "running", "jumping", "jumping2", "downing" },   to = "rolling" },
            ["down"]  = { from = {"rolling", "running", "jumping", "jumping2", "downing" },   to = "downing" },
        }
    }
    local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("panda_run_01.png")
    self:setSpriteFrame(frame)
    self._FSM:init(fsm_init_tbl)
end

