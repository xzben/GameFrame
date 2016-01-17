local MessageType = {}


MessageType.model2view = {}
MessageType.view2model = {}
-----------------model 2 view---------------------------------------------
local baseId = 0
MessageType.model2view.StartGame = baseId + 1
MessageType.model2view.EndGame   = baseId + 2



MessageType.model2view.EndFrame  = baseId + 10000
-----------------view 2 model---------------------------------------------
local baseId = 100000
MessageType.view2model.StartGame = baseId + 1
MessageType.view2model.EndGame   = baseId + 2


return MessageType