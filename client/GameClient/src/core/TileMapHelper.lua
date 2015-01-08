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

function TileMapHelper.get_tile_pos_from_location( tile_map_obj, touch_point )
	local touch_point = cc.pSub(touch_point, cc.p(tile_map_obj:getPosition()))

	local map_scale 	= tile_map_obj:getScale()
	local content_scale = CC_CONTENT_SCALE_FACTOR()

	local map_size  = tile_map_obj:getMapSize()
	local tile_size = tile_map_obj:getTileSize()

	tile_size.width = tile_size.width*content_scale*map_scale
	tile_size.height = tile_size.height*content_scale*map_scale

	local x = math.floor( touch_point.x / tile_size.width )
	local y = math.floor( (map_size.height * tile_size.height - touch_point.y)/tile_size.height )
	
	x = math.max(0, x)
	x = math.min(map_size.width-1, x)
	y = math.max(0, y)
	y = math.min(map_size.height-1, y)

	return cc.p( x, y)
end

function TileMapHelper.get_45_tile_pos_from_location( tile_map_obj, touch_point )
	local touch_point = cc.pSub(touch_point, cc.p(tile_map_obj:getPosition()))

	local map_scale 	= tile_map_obj:getScale()
	local content_scale = CC_CONTENT_SCALE_FACTOR()

	local map_width = tile_map_obj:getMapSize().width
	local map_height = tile_map_obj:getMapSize().height
	local tile_width = tile_map_obj:getTileSize().width*content_scale*map_scale
	local tile_height = tile_map_obj:getTileSize().height*content_scale*map_scale

	local pos_x = math.floor( (touch_point.x - tile_width*touch_point.y/tile_height + tile_width*map_width/2)/tile_width )
	local pos_y = math.floor( map_height - (touch_point.y + tile_height*touch_point.x/tile_width - tile_height*map_height/2)/tile_height )


	pos_x = math.max(0, pos_x)
	pos_x = math.min(tile_map_obj:getMapSize().width-1, pos_x)
	pos_y = math.max(0, pos_y)
	pos_y = math.min(tile_map_obj:getMapSize().height-1, pos_y)
	
	return cc.p( pos_x, pos_y)
end