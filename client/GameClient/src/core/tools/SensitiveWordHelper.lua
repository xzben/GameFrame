-------------------------------------------------------------------------------
-- @file SensitiveWordHelper.lua 
--
--
-- 用于过滤敏感字
--
-------------------------------------------------------------------------------

local crab_core = require("crab.core")
local crab_utf8 = require("utf8.core")

local SensitiveWordHelper = class("SensitiveWordHelper")

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

return SensitiveWordHelper