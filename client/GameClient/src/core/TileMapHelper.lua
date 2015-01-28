-------------------------------------------------------------------------------
-- @file TileMapHelper.lua
--
-- 瓦片地图助手
-------------------------------------------------------------------------------

CC_CONTENT_SCALE_FACTOR = function()
    return cc.Director:getInstance():getContentScaleFactor()
end

CC_POINT_PIXELS_TO_POINTS = function(pixels)
    return cc.p(pixels.x/CC_CONTENT_SCALE_FACTOR(), pixels.y/CC_CONTENT_SCALE_FACTOR())
end

--将坐标按照缩放比例恢复到原始的坐标值
CC_POINT_POINTS_TO_PIXELS = function(points)
    return cc.p(points.x*CC_CONTENT_SCALE_FACTOR(), points.y*CC_CONTENT_SCALE_FACTOR())
end

TileMapHelper = TileMapHelper or {}


local function orientation_ortho_convert_function( touch_point, tile_width, tile_height, map_width, map_height)
	local pos_x = math.floor( touch_point.x/tile_width)
	local pos_y = math.floor((map_height*tile_height - touch_point.y)/tile_height)
	return pos_x, pos_y 
end

local function orientation_iso_convert_function( touch_point, tile_width, tile_height, map_width, map_height)
	local pos_x = math.floor( (touch_point.x - tile_width*touch_point.y/tile_height + tile_width*map_width/2)/tile_width )
	local pos_y = math.floor( map_height - (touch_point.y + tile_height*touch_point.x/tile_width - tile_height*map_height/2)/tile_height )
	return pos_x, pos_y
end

local CONVERT_FUNC_MAP = {
	[cc.TMX_ORIENTATION_ORTHO] 	= orientation_ortho_convert_function,--正常直角地图
	[cc.TMX_ORIENTATION_ISO] 	= orientation_iso_convert_function,--45度地图
}

function TileMapHelper.get_tile_pos_from_location( tile_map_obj, touch_point )
	local map_orientation = tile_map_obj:getMapOrientation()
	local convert_func 	  = CONVERT_FUNC_MAP[map_orientation]
	assert(convert_func, "目前只支持 cc.TMX_ORIENTATION_ORTHO 和 cc.TMX_ORIENTATION_ISO")

	local touch_point 	  = cc.pSub(touch_point, cc.p(tile_map_obj:getPosition()))
	local map_scale 	= tile_map_obj:getScale()
	local content_scale = CC_CONTENT_SCALE_FACTOR()

	local map_size  = tile_map_obj:getMapSize()
	local tile_size = tile_map_obj:getTileSize()

	tile_size.width = tile_size.width*content_scale*map_scale
	tile_size.height = tile_size.height*content_scale*map_scale

	local x, y = convert_func(touch_point, tile_size.width, tile_size.height, map_size.width, map_size.height)
	
	local ret_x = math.max(0, x)
	ret_x = math.min(map_size.width-1, x)
	ret_y = math.max(0, y)
	ret_y = math.min(map_size.height-1, y)
	
	return cc.p( ret_x, ret_y), cc.p(x, y)
end