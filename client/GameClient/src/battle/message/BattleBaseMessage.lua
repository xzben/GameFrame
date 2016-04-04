local BattleBaseMessage = class("BattleBaseMessage")

---@field   #number type   消息类型
BattleBaseMessage.type = nil
---@field   #number frame  消息所属的帧
BattleBaseMessage.frame = nil
---@function ctor
-- @param #number type
function BattleBaseMessage:ctor(type)
	self.type = type
end

function BattleBaseMessage:removeClass()
	self.class = nil
	setmetatable(self, nil)
end

function BattleBaseMessage:isModelEndFrame()
	return self.type == battle.message.MessageType.model2view.EndFrame
end

function BattleBaseMessage:printSelf( header )
	print(string.format("---------- %s ------------", header or "BattleBaseMessage"))
	for key, value in pairs(self) do
		print(key, ":", value)
	end
end

return BattleBaseMessage