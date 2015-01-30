-------------------------------------------------------------------------------
-- @file PathFindHelper.lua
--
-- 使用 AStart 寻路算法实现
-- 寻路算法助手
-------------------------------------------------------------------------------

PathFindHelper = PathFindHelper or class("PathFindHelper", EventDispatcher)

local MOVE_DIR = {
	LEFT 			= 1,
	RIGHT 			= 2,
	TOP 			= 3,
	BOTTOM			= 4,

	LEFT_TOP 		= 5,
	LEFT_BOTTOM 	= 6,
	RIGHT_TOP		= 7,
	RIGHT_BOTTOM 	= 8,
}

local MOVE_OFFSET = {
	[MOVE_DIR.LEFT] 		= {{-1, 0}, 10},
	[MOVE_DIR.RIGHT] 		= {{ 1, 0}, 10},
	[MOVE_DIR.TOP] 			= {{ 0, 1}, 10},
	[MOVE_DIR.BOTTOM] 		= {{ 0,-1}, 10},
	[MOVE_DIR.LEFT_TOP] 	= {{-1, 1}, 14},
	[MOVE_DIR.LEFT_BOTTOM] 	= {{-1,-1}, 14},
	[MOVE_DIR.RIGHT_TOP] 	= {{ 1, 1}, 14},
	[MOVE_DIR.RIGHT_BOTTOM] = {{ 1,-1}, 14},
}

function PathFindHelper:ctor(map_data, width, height, check_block_func)
	self._map_data 		= map_data
	self._map_width 	= width
	self._map_height  	= height
	self._check_block_func = check_block_func

	self:init()
end

function PathFindHelper:get_point_index( point )
	return (point.x + point.y*self._map_width + 1)
end

--检查点是否是阻塞不可走的
function PathFindHelper:check_point_is_block( point )
	if point.x < 0 or point.x >= self._map_width or point.y < 0 or point.y >= self._map_height then
		return true
	end

	local index = self:get_point_index(point)
	if self._check_block_func and type(self._check_block_func) == "function" then
		return self._check_block_func(self._map_data[index])
	else
		return self._map_data[index] ~= 0
	end
end

function PathFindHelper:get_h_value(p1, p2)
	return (math.abs(p1.x - p2.x) + math.abs(p1.y - p2.y))*10
end

function PathFindHelper:find_path( start_point, end_point, only_cross)
	local only_cross = only_cross or false
	local can_move_dirs = {MOVE_DIR.TOP, MOVE_DIR.BOTTOM, MOVE_DIR.LEFT, MOVE_DIR.RIGHT}
	if not only_cross then
		table.insert(can_move_dirs, MOVE_DIR.LEFT_TOP)
		table.insert(can_move_dirs, MOVE_DIR.LEFT_BOTTOM)
		table.insert(can_move_dirs, MOVE_DIR.RIGHT_TOP)
		table.insert(can_move_dirs, MOVE_DIR.RIGHT_BOTTOM)
	end

	local end_index = self:get_point_index(end_point)

	open_list = {}
	open_check_index = {}
	local item_value = { point = start_point, g_cost = 0, h_cost = self:get_h_value(start_point, end_point), parent = nil}
	table.insert(open_list, item_value )
	local open_index = self:get_point_index(start_point)
	open_check_index[open_index] = item_value

	local function open_cmp(a, b)
		local f_a = a.g_cost + a.h_cost
		local f_b = b.g_cost + b.h_cost

		return f_a > f_b
	end

	local close_list = {}
	local end_point_item = nil
	while 1 do
		table.sort(open_list, open_cmp)
		local open_item  = table.remove(open_list)
		if not open_item then
			break
		end
		local cur_point  = open_item.point
		local cur_index  = self:get_point_index( cur_point )
		local cur_g_cost = open_item.g_cost
		local cur_h_cost = open_item.h_cost

		close_list[cur_index] = true --标记当前点为检查过的点

		for _, dir in pairs(can_move_dirs) do
			local offset = MOVE_OFFSET[dir]
			local move_offset = offset[1]
			local move_g_cost = offset[2]
			
			local dest_point = cc.p(cur_point.x + move_offset[1], cur_point.y + move_offset[2])
			if dest_point.x >= 0 and dest_point.x < self._map_width and dest_point.y >= 0 and dest_point.y < self._map_height then
				--print("### x: ", dest_point.x, " ### y: ", dest_point.y)
				local dest_index = self:get_point_index( dest_point )
				local dest_h_cost = self:get_h_value(dest_point, end_point)
				local dest_g_cost = move_g_cost + cur_g_cost
				
				--如果已经在检查过的点中，或不可行走的点
				if close_list[dest_index] or self:check_point_is_block(dest_point) then
					if not close_list[dest_index] then
						--print(dest_point.x, dest_point.y, "is blocked", self._map_data[dest_index])
					end
					--直接跳过
				else
					--如果此点已经在开启列表中
					local open_record = open_check_index[dest_index]
					if  open_record then
						local recore_f = open_record.g_cost + open_record.h_cost
						local dest_f = dest_g_cost + dest_h_cost

						if dest_f < recore_f then
							open_record.parent = open_item
						end
					else
						local item_value = { point = dest_point, g_cost = dest_g_cost, h_cost = dest_h_cost, parent = open_item}
						table.insert(open_list, item_value)
						open_check_index[dest_index] = item_value
					end
				end
			end
		end

		if open_check_index[end_index] then
			end_point_item = open_check_index[end_index]
			break
		end
	end

	if not end_point_item then return nil end

	local path = {}
	table.insert(path, 1, end_point_item.point)

	local loop = end_point_item.parent
	while loop do
		table.insert(path, 1, loop.point)
		loop = loop.parent
	end
	return path
end


function PathFindHelper:init()

end