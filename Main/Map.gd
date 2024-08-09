class_name Map
extends TileMap

export(String) var wall_name := "tree"
export(String) var border_name := "wall"
export(String) var room_name := "room"

func get_wall_id():
	return tile_set.find_tile_by_name(wall_name)

func get_room_id():
	return tile_set.find_tile_by_name(room_name)

func get_border_id():
	return tile_set.find_tile_by_name(border_name)

func is_cell_walkable(position) -> bool:
	var cellv = get_cellv(position)
	if cellv == get_wall_id() or cellv == get_border_id():
		return false
	return true
