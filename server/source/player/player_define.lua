local class, classHelper = require "class"
--
-- 玩家类的定义部分
--

CPlayer = class("CPlayer")

----------------------------------
require "player/player_login"
require "player/player_handle"

----------------------------------
function CPlayer:ctor()

end

function CPlayer:destroy()

end

function CPlayer:init()

end

return CPlayer
