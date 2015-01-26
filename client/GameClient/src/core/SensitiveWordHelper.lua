-------------------------------------------------------------------------------
-- @file SensitiveWordHelper.lua 
--
--
-- 用于过滤敏感字
--
-------------------------------------------------------------------------------

local crab_core = require("crab.core")
local crab_utf8 = require("utf8.core")

SensitiveWordHelper = SensitiveWordHelper or class("SensitiveWordHelper")

function SensitiveWordHelper:ctor(propFilterWords)
	local words = {}
	for _, line in ipairs(propFilterWords) do
	    local t = {}
	    assert(crab_utf8.toutf32(line, t), "non utf8 words detected:"..line)
	    table.insert(words, t)
	end
	self._crab_obj = crab_core.new_crab_obj(words)
end

function SensitiveWordHelper:filter_word( fliter_str )
	local texts = {}
	assert(crab_utf8.toutf32(fliter_str, texts), "non utf8 words detected:", texts)
	local have_filter = crab_core.filter_word(self._crab_obj, texts)
	local output = crab_utf8.toutf8(texts)

	return output, have_filter
end

function SensitiveWordHelper:destroy()
	crab_core.delete_crab_obj(self._crab_obj)
end

---[[ use example
require_ex("Profiles.propFilterWords") --262.3798828125 KB
local crab_obj = SensitiveWordHelper.new(propFilterWords)
-- 初始化过后可以将配置表释放，因为一般敏感字都比较多，所以配置表比较占内存。而初始化过后敏感字信息都已经存储在crab_obj中了
propFilterWords = nil	
collectgarbage("collect")
print( crab_obj:filter_word("我今天10颁奖, 你10颁奖, 他10颁奖") )
crab_obj:destroy()
--]]