--[[
 	此文件用于存放配置参数
--]]


-- 适配最小屏幕尺寸，系统会保证在任何分辨率时UI的尺寸都大于或等于此吃寸
MIN_VIEW_SIZE = cc.size(960, 640)
-- 是否显示 游戏的帧频
SHOW_FPS 	= true
-- 每多少秒显示刷一帧
FPS_INTERVA = 1/60.0


URL_SERVER_ROOT = "http://192.168.1.112:88/admin/version/"
SERVER_HOST = "192.168.19.132"
SERVER_PORT = 3000

-- 错误日志
-- 配置是否发送客户端的错误日志 当不为 nil 且 等于 "send" 就会发送客户端日志
--ERRLOG_SEND = "send"
-- 日志发送的地址
--URL_ERR_LOG = URL_SERVER_ROOT.."client_lua_err.php"