-------------------------------------------------------------------------------
-- @file GameScene.lua 
--
--
-- 游戏主场景
--
-------------------------------------------------------------------------------

GameScene = GameScene or class("GameScene", EventDispatcher)


function GameScene.create()
	return GameScene.extend(cc.Scene:create())
end

function GameScene:ctor()

	
	local function handlercallback(event)
        if "enter" == event then
            self:on_enter()
        elseif "exit" == event then
            self:on_exit()
        end
    end
    self:registerScriptHandler(handlercallback)	
end

function GameScene:on_enter( )
	self:init()
end

function GameScene:on_exit( )
	--self:destroy()
end

function GameScene:init()
    CocoStudioHelper.load_scene(self, "publish/FightScene.csb")
    FightUI.extend(self:get_component_by_name("ui", "GUIComponent"))
    self.hero_img_ = self:get_component_by_tag(10010, "CCSprite")
    self.hero_img_:setVisible(false)

    local fsm_init_tbl = {
        init_state = "attack",
        states = {
            ["idle"]    = { enter = function (self, to_state, from_state, event_name)
                                        print("####### event_name ###", event_name, "from_state ", from_state, " to_state ", to_state, "####################################") 
                                        self:getAnimation():play("loading") 
                                    end, leave = nil },
            ["running"] = { enter = function (self, to_state, from_state, event_name) 
                                        print("####### event_name ###", event_name, "from_state ", from_state, " to_state ", to_state, "####################################")
                                        self:getAnimation():play("run") 
                                    end, leave = nil },
            ["attack"]  = { enter = function (self, to_state, from_state, event_name) 
                                        print("####### event_name ###", event_name, "from_state ", from_state, " to_state ", to_state, "####################################") 
                                        self:getAnimation():play("attack") 
                                    end, leave = nil },
            ["hurt"]    = { enter = function (self, to_state, from_state, event_name) 
                                        print("####### event_name ###", event_name, "from_state ", from_state, " to_state ", to_state, "####################################") 
                                        self:getAnimation():play("smitten") 
                                    end, leave = nil },
            ["dead"]    = { enter = function (self, to_state, from_state, event_name) 
                                        print("####### event_name ###", event_name, "from_state ", from_state, " to_state ", to_state, "####################################") 
                                        self:getAnimation():play("death") 
                                    end, leave = nil },   
        },
        events = {
            ["stop"]    = { from = {"idle", "running", "attack" },          to = "idle" },
            ["attack"]  = { from = {"idle", "running", "attack", "hurt" },  to = "attack" },
            ["hurt"]    = { from = {"idle", "running", "attack", "hurt" },  to = "hurt" },
            ["run"]     = { from = {"idle", "running", "attack", "hurt"},   to = "running" },
            ["die"]     = { from = {"idle", "running", "attack", "hurt"},   to = "dead" },
        }
    }
    self._hero  = FiniteStateMachine.extend( self:get_component_by_name("hero", "CCArmature") )
    self._enemy = FiniteStateMachine.extend( self:get_component_by_name("enemy", "CCArmature") )
    self._hero:init(fsm_init_tbl)
    self._enemy:init(fsm_init_tbl)

    local events = {"stop", "attack", "hurt", "run"}

    local function random_event() 
        local index = math.random(1, 4)
        self._hero:do_event(events[index])
        self._enemy:do_event(events[index])
        self:timeout(0.5, random_event)
    end

    self:timeout(0.5, random_event)

end