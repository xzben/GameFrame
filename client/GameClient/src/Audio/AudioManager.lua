-------------------------------------------------------------------------------
-- @file AudioManager.lua
--
-- @ author xzben 2015/06/18
--
-- 所有显示音频管理类
-------------------------------------------------------------------------------

AudioManager = AudioManager or class("AudioManager", EventDispatcher)


function AudioManager.create()
	return AudioManager.extend(cc.SimpleAudioEngine:getInstance())
end

function AudioManager:ctor()
	self:init()
end

function AudioManager:isOpenMusic()
	return GSession._player:isMusicOpen()
end

function AudioManager:handle_playEffect(sender, effectType, loop)
	if not self:isOpenMusic() then return end

	local loop = loop or false
	local effectNameMap = {
		["btnClick"] = "music/anniu.ogg",
		["cellMove"] = "music/move.ogg",
	}

	if not effectNameMap[effectType] then return end
    return self:playEffect(effectNameMap[effectType], loop)
end

function AudioManager:handle_stopAllEffect()
	self:stopAllEffects()
end

function AudioManager:handle_playBackgroundMusic()
	if self:isOpenMusic() then
    	--cc.SimpleAudioEngine:getInstance():playMusic("", true)
    end
end

function AudioManager:init()
	HandleRequestEvent("playBGM", self.handle_playBackgroundMusic, self)
	HandleRequestEvent("playEffect", self.handle_playEffect, self)
	HandleRequestEvent("stopAllEffect", self.handle_stopAllEffect, self)
end