-------------------------------------------------------------------------------
-- @file MPlayer.lua
--
-- @ author xzben 2015/05/19
--
-- 玩家数据
-------------------------------------------------------------------------------

MPlayer = MPlayer or class("MPlayer", MBase)


function MPlayer:ctor()
	self._record = 0
	self._musicOpen = true
	self:init()
end

function MPlayer:getDataFromDB()
	self._record = cc.UserDefault:getInstance():getIntegerForKey("MPlayer.Record", 0)
	self._musicOpen = cc.UserDefault:getInstance():getBoolForKey("AudioManager.openAudio", true)
end

function MPlayer:saveDataToDB()
	cc.UserDefault:getInstance():setIntegerForKey("MPlayer.Record", self._record)
	cc.UserDefault:getInstance():getBoolForKey("AudioManager.openAudio", self._musicOpen)
end

function MPlayer:getRecord()
	return self._record
end

function MPlayer:isMusicOpen()
	return self._musicOpen
end

function MPlayer:switchAudio()
	self._musicOpen = not self._musicOpen
	self:saveDataToDB()
	
	if self._musicOpen then
		RequestEvent("playBGM")
	end
end


function MPlayer:updateRecord( score )
	if score > self._record then
		self._record = score
	end
	self:saveDataToDB()
end

function MPlayer:init()
	
end
