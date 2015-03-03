LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := cocos2dlua_shared

LOCAL_MODULE_FILENAME := libcocos2dlua

LOCAL_SRC_FILES := hellolua/main.cpp \
                   ../../Classes/AppDelegate.cpp \
				   ../../Classes/crab/lua_crab.cpp \
				   ../../Classes/crab/lua_utf8.cpp \
				   ../../Classes/lua_register/luaNetwork.cpp \
				   ../../Classes/network/MemoryPool.cpp \
				   ../../Classes/network/Mutex.cpp \
				   ../../Classes/network/network.cpp \
				   ../../Classes/network/packet.cpp \
				   ../../Classes/lua52.cpp \
				   ../../Classes/pbc-lua.cpp
				   
				   


LOCAL_C_INCLUDES := $(LOCAL_PATH)/../../Classes
					
LOCAL_STATIC_LIBRARIES := cocos2d_lua_static
LOCAL_WHOLE_STATIC_LIBRARIES += pbc

include $(BUILD_SHARED_LIBRARY)

$(call import-module,scripting/lua-bindings/proj.android)
$(call import-module,scripting/lua-bindings/proj.android)
$(call import-module,../../../../3rd/pbc)
