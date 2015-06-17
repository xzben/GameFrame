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

	self:init()
end

function MPlayer:getRecordFromDB()
	return cc.UserDefault:getInstance():getIntegerForKey("MPlayer.Record")
end

function MPlayer:saveRecordToDB()
	cc.UserDefault:getInstance():setIntegerForKey("MPlayer.Record", self._record)
end

function MPlayer:getRecord()
	return self._record
end

function MPlayer:updateRecord( score )
	if score > self._record then
		self._record = score
	end
	self:saveRecordToDB()
end


function MPlayer:init()
	self._record = self:getRecordFromDB()
end
