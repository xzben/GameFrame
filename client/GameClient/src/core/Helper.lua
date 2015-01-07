Helper = Helper or {}

CC_CONTENT_SCALE_FACTOR = function()
    return cc.Director:getInstance():getContentScaleFactor()
end


CC_POINT_PIXELS_TO_POINTS = function(pixels)
    return cc.p(pixels.x/CC_CONTENT_SCALE_FACTOR(), pixels.y/CC_CONTENT_SCALE_FACTOR())
end

CC_POINT_POINTS_TO_PIXELS = function(points)
    return cc.p(points.x*CC_CONTENT_SCALE_FACTOR(), points.y*CC_CONTENT_SCALE_FACTOR())
end

function Helper.create_auto_node(enter_func, exit_func)
	local autoNode = cc.Node:create()
	
	local function on_enter()
		if enter_func then
			enter_func()
		end
	end

	local function on_exit()
		if exit_func then
			exit_func()
		end
	end

	local function handlercallback(event)
        if "enter" == event then
            on_enter()
        elseif "exit" == event then
            on_exit()
        end
    end
    autoNode:registerScriptHandler(handlercallback)	

    return autoNode
end

-- 将文件完整名，拆分成 文件名 和 扩展名
-- 如 filename.txt  将返回  filename  txt
function Helper.split_filename_ext(filepath)
	local filename, ext = string.match (filepath, "^(.*)%.(.*)$")

	return filename, ext
end

--[[
	深度查找 node 的子节点通过节点的 name
--]]
function Helper.seek_child_by_name(root, name)
	local function search_node(node)
		if node == nil then 
			return 
		end

		if node:getName() == name then
			return node
		end

		local childrens = node:getChildren()
		for _, child in pairs(childrens) do
			local ret = search_node(child)
			if ret then
				return ret
			end
		end
	end
	
	return search_node(root)
end
--[[
	深度查找 node 的子节点通过节点的 tag
--]]
function Helper.seek_child_by_tag(root, tag)
	local function search_node(node)
		if node == nil then 
			return 
		end

		if node:getTag() == tag then
			return node
		end

		local childrens = node:getChildren()
		for _, child in pairs(childrens) do
			local ret = search_node(child)
			if ret then
				return ret
			end
		end
	end
	
	return search_node(root)
end