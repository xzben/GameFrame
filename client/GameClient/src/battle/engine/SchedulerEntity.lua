local SchedulerEntity = class("SchedulerEntity")

---@field #number _tag  		标记
SchedulerEntity._tag = nil
---@field #number  _rate    	调度周期 单位为帧数
SchedulerEntity._rate = nil
---@field #number _count 		调度计数器
SchedulerEntity._count = 0 
---@field #function _callback 	回调函数
SchedulerEntity._callback = nil
---@field #Object   _owner    	回调函数所属obj
SchedulerEntity._owner = nil
---@filed #boolean _pause 		是否暂停
SchedulerEntity._pause = nil

function SchedulerEntity:ctor( tag, pause, rate, callback, owner )
	self._tag = tag
	self._pause = pause or false
	self._rate  = rate or 1
	self._callback = callback
	self._owner = owner
	self._count = 0
end

function SchedulerEntity:reset()
	self._count = 0
end

function SchedulerEntity:pause()
	self._pause = true
end

function SchedulerEntity:resume()
	self._pause = false
end

function SchedulerEntity:run(...)
	if self._pause then return end

	self._count = self._count + 1
	if self._count >= self._rate then
		self._count = 0

		if self._owner then
			self._callback( self._owner, ...)
		else
			self._callback( ... )
		end
	end
end

return SchedulerEntity