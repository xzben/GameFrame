--[[
	此目录下存放所有基础功能的封装
	1、CocoStudioHelper.lua   	实现 cocostudio 相关的辅助功能实现
	2、DragSprite.lua		  	实现一个可以拖拽的 Sprite 控件
	3、EventDispatcher.lua	  	实现一个事件派发功能的基础类，所有继承此类的子类可以通过 add_listener、dispatch_event 添加监听，和派发事件
	4、FiniteStateMachine.lua 	实现一个有限状态机功能
	5、Helper.lua			  	实现一个程序中需要辅助功能
	6、LoadDelay.lua		  	实现一个按帧分帧加载的加载器
	7、SensitiveWordHelper.lua	实现一个敏感字过滤的辅助器
	8、SmartPageView.lua  		实现一个智能加载子页的PageView(翻页控件)控件，此控件可以按照需求动态加载子页
	9、ScrollMap.lua			实现一个滚动底图控件
--]]