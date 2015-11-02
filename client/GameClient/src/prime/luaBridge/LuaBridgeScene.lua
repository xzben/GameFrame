local LuaBridgeScene = class("LuaBridgeScene", prime.common.VBase)

function LuaBridgeScene.create()
	return LuaBridgeScene.extend(cc.Scene:create())
end

function LuaBridgeScene:ctor()
	self:init()
end

function LuaBridgeScene:on_enter( )
	
end

function LuaBridgeScene:on_exit( )
	self:destroy()
end

function LuaBridgeScene:handleKeyBackClicked()
    game.session():popScene()
end

function LuaBridgeScene:init()

    local function addInput( strTitle, pos )
        local title = ccui.Text:create()
        title:setString(strTitle)
        title:setFontSize(25)
        title:setPosition(pos)
        self:addChild(title)

        local textField = ccui.TextField:create()
        textField:setTouchEnabled(true)
        textField:setFontSize(25)
        textField:setPlaceHolder("input a number")
        textField:setPosition(cc.p(pos.x + title:getContentSize().width + 50, pos.y))
        self:addChild(textField)

        return textField
    end
    local visibleSize = core.VisibleRect:getVisibleSize()
    local posY = visibleSize.height - 50
    
    local title = ccui.Text:create()
    title:setString("test LuaBridge")
    title:setFontSize(30)
    title:setPosition(cc.p(visibleSize.width/2, posY))
    self:addChild(title)
    local gap = 60
    posY = posY - gap
    local inputA = addInput("number a: ", cc.p(visibleSize.width/2-150, posY))
    posY = posY - gap
    local inputB = addInput("number b: ", cc.p(visibleSize.width/2-150, posY))
    posY = posY - gap

    local result = ccui.Text:create()
    result:setFontSize(30)
    result:setString("the result is: ")
    result:setPosition(cc.p(visibleSize.width/2, posY))
    posY = posY - gap
    self:addChild(result)

    local button = ccui.Button:create()
    button:setTouchEnabled(true)
    button:loadTextures("ui/yellow_edit.png", "")
    button:setTitleText("确定")
    button:setScale9Enabled(true)
    button:setContentSize(cc.size(100, 50))
    button:setPosition(cc.p(visibleSize.width/2, posY))
    button:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local a = tonumber(inputA:getString())
            local b = tonumber(inputB:getString())

            local c, platform = core.LuaBridge:addTwoNumbers(a, b)

            result:setString("the result is: " .. tostring(c) .. " platform:  ".. platform)
        end
    end)
    self:addChild(button)
    posY = posY - gap

    local textField = ccui.TextField:create()
    textField:setTouchEnabled(true)
    textField:setFontSize(25)
    textField:setPlaceHolder("input a string")
    textField:setPosition(cc.p(visibleSize.width/2 - 200, posY))
    self:addChild(textField)

    local copyButton = ccui.Button:create()
    copyButton:setTouchEnabled(true)
    copyButton:loadTextures("ui/yellow_edit.png", "")
    copyButton:setTitleText("复制")
    copyButton:setScale9Enabled(true)
    copyButton:setContentSize(cc.size(100, 50))
    copyButton:setPosition(cc.p(visibleSize.width/2+100, posY))
    copyButton:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
           core.LuaBridge:copyToClipboard(textField:getString())
        end
    end)
    self:addChild(copyButton)
    posY = posY - gap

    local pasteText = ccui.Text:create()
    pasteText:setString("LuaBridge pasteFromClipboard Test..")
    pasteText:setFontSize(25)
    pasteText:setPosition(cc.p(visibleSize.width/2-200, posY))
    self:addChild(pasteText)

    local pasteButton = ccui.Button:create()
    pasteButton:setTouchEnabled(true)
    pasteButton:loadTextures("ui/yellow_edit.png", "")
    pasteButton:setTitleText("粘贴")
    pasteButton:setScale9Enabled(true)
    pasteButton:setContentSize(cc.size(100, 50))
    pasteButton:setPosition(cc.p(visibleSize.width/2+100, posY))
    pasteButton:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            pasteText:setString(core.LuaBridge:pasteFromClipboard())
        end
    end)
    self:addChild(pasteButton)
    posY = posY - gap
end

return LuaBridgeScene