-------------------------------------------------------------------------------
-- @file FightUI.lua 
--
--
-- 游戏场景中的展示UI
--
-------------------------------------------------------------------------------

FightUI = FightUI or class("FightUI", EventDispatcher)

function FightUI:ctor()
	self:init()
end

function FightUI:init_control_image_vs( control_obj )
	control_obj:setVisible(false)
end

function FightUI:control_init_left_hp_progress(control_obj)
	control_obj:setPercent(50)
end

function FightUI:control_init_left_mp_progress(control_obj)
	control_obj:setPercent(50)
end

function FightUI:control_init_right_hp_progress(control_obj)
	control_obj:setPercent(50)
end

function FightUI:control_init_right_mp_progress(control_obj)
	control_obj:setPercent(50)
end

local FightUIControls = {
	{tag_name 	= "hp01_LoadingBar", 	init_callback 	= FightUI.control_init_left_hp_progress},
	{tag_name 	= "mp01_LoadingBar", 	init_callback 	= FightUI.control_init_left_mp_progress},
	{tag_name 	= "hp02_LoadingBar", 	init_callback 	= FightUI.control_init_right_hp_progress},
	{tag_name 	= "mp02_LoadingBar", 	init_callback 	= FightUI.control_init_right_mp_progress},
}

function FightUI:init()
	CocoStudioHelper.init_ui_controls(self, FightUIControls)
end