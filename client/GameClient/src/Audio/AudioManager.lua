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
	self._isOpenAudio = cc.UserDefault:getInstance():getBoolForKey("AudioManager.openAudio", true)
	self:init()
end

function AudioManager:switchAudio()
	self._isOpenAudio = not self._isOpenAudio
	cc.UserDefault:getInstance():setBoolForKey("AudioManager.openAudio", self._isOpenAudio)
	RequestEvent("playBGM")
end

function AudioManager:handle_playEffect(sender, effectType, loop)
	if not self._isOpenAudio then return end

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
	if self._isOpenAudio then
    	--cc.SimpleAudioEngine:getInstance():playMusic("", true)
    end
end

function AudioManager:init()
	HandleRequestEvent("playBGM", self.handle_playBackgroundMusic, self)
	HandleRequestEvent("playEffect", self.handle_playEffect, self)
	HandleRequestEvent("stopAllEffect", self.handle_stopAllEffect, self)
	HandleRequestEvent("switchAudio", self.switchAudio, self)
end