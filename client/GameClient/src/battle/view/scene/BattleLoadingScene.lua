local BattleLoadingScene = class("BattleLoadingScene")

function BattleLoadingScene.create( model )
	return BattleLoadingScene.extend(cc.Scene:create(), model )
end

function BattleLoadingScene:ctor( model )
	self:init( model )
end

function BattleLoadingScene:init( model )
	local lbl = ccui.Text:create()
	lbl:setString("Loading......")
    lbl:setFontSize(20)
	lbl:ignoreAnchorPointForPosition(false)
	lbl:setAnchorPoint(cc.p(0.5, 0.5))
	lbl:setPosition(core.VisibleRect:center())
	self:addChild(lbl)
end

return BattleLoadingScene