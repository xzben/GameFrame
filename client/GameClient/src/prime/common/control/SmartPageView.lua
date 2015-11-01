-------------------------------------------------------------------------------
-- @file SmartPageView.lua
--
--
-- 只能的翻页容器，能够智能的去加载page，而不是一次性就把页面加载完（这样第一次加载时间过长） 
-- 使用的时候请用   SmartPageView.extend(cc.Layer:create(), ... ) 的方式创建
-------------------------------------------------------------------------------

local SmartPageView = class("SmartPageView", core.EventDispatcher)

local SmartPageDir = {
	SCROLL_LEFT_RIGHT = 1,
	SCROLL_TOP_BOTTOM = 2,
}

local SmartPageEvent = {
	CHANGE_PAGE = 1,
}

SmartPageView.SmartPageDir = SmartPageDir
SmartPageView.SmartPageEvent = SmartPageEvent


function SmartPageView.create( page_iterator, all_page_num, scroll_dir, pre_load_num, size, is_swallow_touch_event)
	return SmartPageView.extend(cc.Layer:create(), page_iterator, all_page_num, scroll_dir, pre_load_num, size, is_swallow_touch_event)
end

-- page_iterator 是一个创建页面的接口函数
--[[
	function page_iterator(page_index, page_size)
		return   根据 page_index 和 page_size 生成一个页面
	end
--]]
-- all_page_num  总共有多少个页面
-- scroll_dir 	 翻页的效果，左右翻页还是上下翻页
-- pre_load_num  前后预先加载的数目 -- 如为 1 则表示前后各预加载一页。
-- 当换页的时候 发现 前/后 不够预加载数目则会自动加载  
-- size 		page_view  的 size
function SmartPageView:ctor( page_iterator , all_page_num, scroll_dir, pre_load_num, size, is_swallow_touch_event)
	self.all_page_num_			= math.ceil(all_page_num) 	-- 总共的页面数目
	self.page_create_iterator_	= page_iterator -- 创建 page 的迭代器
	self.cur_page_index_ 		= 1 	 		-- 当前所在的 page 的 index
	self.pages_			 		= {}			-- 容器中所有 page 的集合
	self.scroll_dir_			= scroll_dir 	-- 容器翻页的方向 上下 or 左右
	self.pre_load_num_			= math.floor(pre_load_num)
	-- 容器是否要吞噬其接收到的 touch event，如果吞噬则其后的控件将接收不到被它遮挡的touch事件

	self.touch_end_layer_ = nil
	self.content_layer_ = nil   --容器layer
	self.touch_layer_ = nil  	--触摸layer

	self:setContentSize(size)
	self:init()

    local function handlercallback(event)
        if "enter" == event then
            self:on_enter()
        elseif "exit" == event then
            self:on_exit()
        end
    end
    self:registerScriptHandler(handlercallback)	
end

function SmartPageView:on_enter( )
	
end

function SmartPageView:on_exit( )
	
end

function SmartPageView:set_per_load_num( pre_load_num )
	self.pre_load_num_ = pre_load_num
end

function SmartPageView:get_cur_page_index()
	return self.cur_page_index_
end

function SmartPageView:get_all_page_num()
	return self.all_page_num_
end

-- 检查索引的有效性，并返回有效的值
function SmartPageView:check_index( index )
	if index > self.all_page_num_ then
		index = self.all_page_num_
	elseif index < -1*self.all_page_num_ then
		index = -1*self.all_page_num_
	end

	return index
end
-- start_index ，end_index 要加载页面的范围
-- 可以用负索引， 比如 -1 为左后一页，-2 倒数第二页  0 是无效的。 1 代表第一页， 2 代表第二页
-- 如果一个页面都没加载 则返回 false
function SmartPageView:load_page( start_index, end_index)
	-- 如果本身全部页面就为0 则直接返回true
	if self.all_page_num_ == 0 then return true end

	local loaded_num = 0
	start_index = self:check_index(start_index)
	end_index	= self:check_index(end_index)
	--print(string.format("load page from [%d] to [%d]", start_index, end_index))
	assert(start_index <= end_index, "the SmartPageView load_page index must start_index <= end_index")

	local page_view_size = self:getContentSize()

	for i = start_index, end_index , 1 do
		if i ~= 0 then
			index = i
			if index < 0 then
				index = self.all_page_num_ + index + 1
			end

			--print("begin load page :", index)
			if not self.pages_[index] then 
				local new_page = self.page_create_iterator_(index, self:getContentSize())
				if nil ~= new_page then
					loaded_num = loaded_num + 1
					self.pages_[index] = new_page
					new_page:setVisible(false)
					new_page:setPosition(page_view_size.width/2, page_view_size.height/2)
					self.content_layer_:addChild(new_page)
					--print("loaded page ".. index .. "success")
				end
			end
		end
	end

	return (0 < loaded_num)
end

-- is_next 表示方向 true 表示翻下一页
-- new_index 表示新页index
function SmartPageView:switch_page( is_next, new_index )
	if self.all_page_num_ <= 0 then return end
	
	if new_index and new_index ~= self.cur_page_index_ and -- 不是当前页 
	   self.pages_[new_index]  	   		     -- 页面已经加载成功
	then	
		local b_dir_next = is_next  -- true 为向后，false 向前

		local cur_page  = self.pages_[self.cur_page_index_]
		local next_page  = self.pages_[new_index]

		assert(next_page ~= nil, "when switch page the new page is invalid")
		
		--print("new page index: ", new_index, "all page size is ", self.all_page_num_ )	


		local page_size 	 = next_page:getContentSize()
		local page_view_size = self:getContentSize()

		next_page:ignoreAnchorPointForPosition(false) -- 不忽略锚点
		next_page:setAnchorPoint(0.5, 0.5)  -- 中点
		
		local new_des_pos = cc.p(page_view_size.width/2, page_view_size.height/2)
		local old_des_pos = cc.p(page_view_size.width/2, page_view_size.height/2)

		if self.scroll_dir_ == SmartPageDir.SCROLL_LEFT_RIGHT then
			if b_dir_next then
				old_des_pos = cc.p(-1*page_view_size.width/2, page_view_size.height/2)
				next_page:setPosition(cc.p( page_view_size.width + page_size.width/2, page_size.height/2) )
			else
				old_des_pos = cc.p(3*page_view_size.width/2, page_view_size.height/2)
				next_page:setPosition(cc.p( -1*page_size.width/2, page_size.height/2) )
			end
		elseif self.scroll_dir_ == SmartPageDir.SCROLL_TOP_BOTTOM then
			if b_dir_next then
				old_des_pos = cc.p(page_view_size.width/2, -1*page_view_size.height/2)
				next_page:setPosition(cc.p( page_size.width/2, -1*page_size.height/2) )
			else
				old_des_pos = cc.p(page_view_size.width/2, 3*page_view_size.height/2)
				next_page:setPosition(cc.p( page_size.width/2, page_view_size.height+page_size.height/2) )
			end
		end
		

		local function move_done()
			AudioEngine.playEffect(propMusicSound[17].ResName)
			cur_page:setVisible(false)
			cur_page:setLocalZOrder(1)
		end

		local action_new_move_to 		= cc.MoveTo:create(0.1, new_des_pos)
		local action_old_move_to		= cc.MoveTo:create(0.1, old_des_pos)
		local action_spawn 				= cc.Spawn:create(action_old_move_to, action_new_move_to)

		local actionCallBack = cc.CallFunc:create(move_done)
		local actionSequene = cc.Sequence:create(action_new_move_to, actionCallBack)

		next_page:setVisible(true)
		next_page:setLocalZOrder(self.all_page_num_+1)

		cur_page:runAction(action_old_move_to)
		next_page:runAction(actionSequene)

		 -- 更新index
		self.cur_page_index_ = new_index
		self:dispatch_event(SmartPageEvent.CHANGE_PAGE, new_index, next_page)
	end
end

function SmartPageView:move_to_pre()
	if self.all_page_num_ <= 0 then return end
	local check_load_index = 0

	if self.cur_page_index_ > 1 then
		check_load_index = self.cur_page_index_ - 2
		self:switch_page(false, self.cur_page_index_ - 1)
		if check_load_index == 0 then check_load_index = self.all_page_num_ end
	elseif self.cur_page_index_ == 1 then
		self:switch_page(false, self.all_page_num_)
		check_load_index = self.all_page_num_ - 1
	end

	if check_load_index >= 1 and check_load_index <= self.all_page_num_ and -- 要检测的 page index 有效
	   not self.pages_[check_load_index]  --马上需要用的 page 还没加载  
	then 
		self:load_page(check_load_index - ( self.pre_load_num_ - 1 ) , check_load_index)
	else
		--print("SmartPageView:move_to_pre() check index ".. check_load_index)
	end
end

function SmartPageView:move_to_next()
	if self.all_page_num_ <= 0 then return end
	-- 先翻页，再加载新页
	local check_load_index = 0

	if self.cur_page_index_ < self.all_page_num_ then
		check_load_index = self.cur_page_index_ + 2
		self:switch_page(true, self.cur_page_index_ + 1)
		if check_load_index > self.all_page_num_ then check_load_index = 1 end
	elseif self.cur_page_index_ == self.all_page_num_ then
		self:switch_page(true, 1)
		check_load_index = self.all_page_num_ - self.pre_load_num_ - 1
	end

	if check_load_index >= 1 and check_load_index <= self.all_page_num_ and -- 要检测的 page index 有效
	   not self.pages_[check_load_index]  --马上需要用的 page 还没加载  
	then
		self:load_page(check_load_index, check_load_index + self.pre_load_num_ - 1)
	else
		--print("SmartPageView:move_to_next() check index ".. check_load_index)
	end
end

function SmartPageView:init_touch_event()
	local BeginPos = {x = 0, y = 0}
	
	local cancel_move = false
	local function onTouchBegan(touch, event)
		BeginPos = touch:getLocation()

		local target = event:getCurrentTarget()
        
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)
        
        local function delay_execute()
        	cancel_move = true
        end
        if cc.rectContainsPoint(rect, locationInNode) then
        	--print("in the rect")
        	cancel_move = false
        	self:run_delay(0.5, delay_execute)
            --print("SmartPageView::onTouchBegan")
            return true -- 必不可少
        end
        --print("out the rect")
        return false
	end 

	local function onTouchMoved(touch, event)
		--print("SmartPageView touch moved"..os.time())
	end

	local page_view_size = self:getContentSize()

	local move_min_width = 50
	
	local function onTouchEnd(touch,event)
		if cancel_move then return end
		local location = touch:getLocation()
		
		local nMoveY = location.y - BeginPos.y
		local nMoveX = location.x - BeginPos.x

		local move_dir 	 = 0 --  == 0 表示未知 ， < 0 表示下一个 > 0 表示前一个

		if self.scroll_dir_ == SmartPageDir.SCROLL_LEFT_RIGHT then
			if math.abs(nMoveX) >= move_min_width then
				move_dir = nMoveX 
			end
		elseif self.scroll_dir_ == SmartPageDir.SCROLL_TOP_BOTTOM then
			if math.abs(nMoveY) >= move_min_width then
				move_dir = nMoveY
			end
		else
			assert(false, "SmartPageView error SmartPageDir ["..self.scroll_dir_.."]")
		end

		--  == 0 表示未知 ， < 0 表示下一个 > 0 表示前一个
		if move_dir > 0 then
			self:move_to_pre()
		elseif move_dir < 0 then
			self:move_to_next()
		end
	end
	
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(false)
	listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
	listener:registerScriptHandler(onTouchEnd, 	 cc.Handler.EVENT_TOUCH_ENDED)
	
	local eventDispatcher = self.touch_layer_:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.touch_layer_)


	local function begin_touch_end()
		return true
	end

	local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(true)
	listener:registerScriptHandler(begin_touch_end, cc.Handler.EVENT_TOUCH_BEGAN)
	
	local eventDispatcher = self.touch_end_layer_:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.touch_end_layer_)
end

function SmartPageView:init()
	local layer_size = self:getContentSize()
	self.touch_end_layer_ = cc.LayerColor:create(cc.c4b(0,0,255,0))
	self.content_layer_ = cc.LayerColor:create(cc.c4b(255,0,0,0))
	self.touch_layer_ = cc.LayerColor:create(cc.c4b(0,255,0,0))

	self.touch_end_layer_:setContentSize(layer_size)
	self.content_layer_:setContentSize(layer_size)
	self.touch_layer_:setContentSize(layer_size)
	self:addChild(self.touch_end_layer_)
	self:addChild(self.content_layer_)
	self:addChild(self.touch_layer_)
	--预加载 1 + 2*self.pre_load_num_ 页, 并直接将第一页添加显示
	assert(self:load_page(0 - tonumber(self.pre_load_num_), 1 + self.pre_load_num_), "SmartPageView load page failed.")
	assert(1 == self.cur_page_index_, "SmartPageView:init() the cur page index must be 1.") 

	if self.all_page_num_ > 0 then
		local first_page = self.pages_[self.cur_page_index_]
		assert(first_page, "failed to get first page....")
		first_page:ignoreAnchorPointForPosition(false)
		first_page:setContentSize(layer_size)
		first_page:setAnchorPoint(0.5, 0.5)
		first_page:setPosition(layer_size.width/2, layer_size.height/2)
		first_page:setVisible(true)
		first_page:setLocalZOrder(self.all_page_num_+1)
	end
	self:init_touch_event()
end

return SmartPageView