-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    cclog("----------------------------------------------------")
    cclog("LUA ERROR: " .. tostring(msg) .. "\n")
    local tracestr = debug.traceback()

    if ERRLOG_SEND and ERRLOG_SEND == "send" then
        send_err_log(tracestr)
    end
    
    cclog(tracestr)
    cclog("----------------------------------------------------")
    return msg
end