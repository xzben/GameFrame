local BaseBattleScene = class("BaseBattleScene", prime.common.VBase)

---@field  _model
BaseBattleScene._model = nil

---@function create
---@param  model
function BaseBattleScene.create( model )
	return BaseBattleScene.extend(cc.Scene:create(), model )
end

---@function ctor
---@param  model
function BaseBattleScene:ctor( model )
	self._model = model
	self:init()
end

function BaseBattleScene:init()
	local bg = cc.Sprite:create("ui/battle/loading/loading.png")
	bg:setAnchorPoint(cc.p(0.5,0.5))
	bg:setPosition(core.VisibleRect:center())
	self:addChild(bg)


	local function closeCallback()
		local endMsg = battle.message.BattleBaseMessage.new(battle.message.MessageType.view2model.EndGame)
		battle.view.sendMessage2Model(endMsg)
    end

    local s = core.VisibleRect:getVisibleSize()
    local CloseItem = cc.MenuItemImage:create("ui/close.png", "ui/close.png")
    CloseItem:registerScriptTapHandler(closeCallback)
    CloseItem:setPosition(cc.p(s.width - 30, 30))

    local CloseMenu = cc.Menu:create()
    CloseMenu:setPosition(0, 0)
    CloseMenu:addChild(CloseItem)
    self:addChild(CloseMenu, 100)
end

return BaseBattleScene