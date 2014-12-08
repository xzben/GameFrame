-------------------------------------------------------------------------------
-- @file GSession.lua
--
-- @ author xzben 2014/05/16
--
-- 本文见存放整个游戏的控制逻辑
-------------------------------------------------------------------------------

Session = Session or class("Session", EventDispatcher)

function Session.create()
	return Session.new()	
end

function Session:ctor()
	self._director = cc.Director:getInstance()
	self:init()
end

function Session:session_destroy()
	
end

function Session:init()

end

GSession = GSession or Session.create()

