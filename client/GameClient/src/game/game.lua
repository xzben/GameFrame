--[[
	本文见存放整个游戏的控制逻辑
--]]
module("game", package.seeall)

local Game = class("Game", core.EventDispatcher)

---@field Session
Game._session = nil
---@field Network 
Game._network = nil

---@static_class_field  全局单例
local s_instance = nil

function Game:ctor()
	self:init()
end

function Game:init()
	self._network = core.network.Network.create() --创建网络模块
	self._session = core.Session.create()
end

function Game:session()
	return self._session
end

function Game:network()
	return self._network
end

function Game:lauchScene()
	if self:session():getRunningScene() then
        self:session():popToRootScene()
    end
    self:session():replaceScene(game.prime.LauchScene.create())
end

function Game:hotupdate()
	require_ex("HotCodeInclude")
	self._network:updateProtos()
	self:init()
	self:lauchScene()
end


game.session = function ()
	return game.instance():session()
end

game.instance = function ()
	if s_instance == nil then
		s_instance = Game.new()
	end

	return s_instance
end