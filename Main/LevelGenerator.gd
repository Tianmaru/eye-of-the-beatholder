extends Node2D

export(NodePath) var tile_map_path
export(float) var P_ROOM = 0.5
export(int) var MIN_ROOM_SIZE = 3
export(int) var MAX_ROOM_SIZE = 6
export(int) var MAP_BORDER = 1
export(int) var N_ROOMS = 5
export(Vector2) var MAP_SIZE = Vector2(16, 16)
export(int) var STEP_SIZE = 8
export(String) var TILE_NAME_WALL = "wall"
export(String) var TILE_NAME_BORDER = "border"
export(String) var TILE_NAME_ROOM = "room"

var tile_map : TileMap
var map_position : Vector2
var walk_direction : Vector2
var map_area : Rect2
var walk_area : Rect2
var rooms : Array
var tile_id_wall = 0
var tile_id_border = 0
var tile_id_room = 0

var start_position : Vector2
var end_position : Vector2


const directions := [
	Vector2.UP,
	Vector2.DOWN,
	Vector2.LEFT,
	Vector2.RIGHT
]

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	if tile_map_path:
		tile_map = get_node(tile_map_path) as TileMap


func get_tile_ids():
	var tile_set = tile_map.tile_set
	tile_id_wall = tile_set.find_tile_by_name(TILE_NAME_WALL)
	tile_id_border = tile_set.find_tile_by_name(TILE_NAME_BORDER)
	tile_id_room = tile_set.find_tile_by_name(TILE_NAME_ROOM)

func random_dir():
	var dirs = []
	for d in directions:
		if not d.is_equal_approx(walk_direction * -1) and walk_area.has_point(map_position + d * STEP_SIZE):
			dirs.append(d)
	if len(dirs) == 0:
		# TODO: throws error, if really unfortunate position in between
		print("ERROR", map_position)
		return walk_direction * -1
	return dirs[randi() % len(dirs)]

func reset():
	tile_map.clear()
	rooms = []
	var border = Vector2(MAP_BORDER, MAP_BORDER)
	map_area = Rect2(border, MAP_SIZE - 2*border)
	walk_area = Rect2(map_area.position, map_area.size)
	walk_area.position += int(STEP_SIZE / 2) * Vector2.ONE
	walk_area.size -= STEP_SIZE * Vector2.ONE
	start_position = Vector2()
	start_position.x = walk_area.position.x + randi() % int(walk_area.size.x)
	start_position.y = walk_area.position.y + randi() % int(walk_area.size.y)
	map_position = start_position
	walk_direction = random_dir()

func generate_level():
	print("generating level")
	reset()
	get_tile_ids()
	fill_map()
	make_border()
	make_room()
	while(len(rooms) < N_ROOMS):
		walk_steps(STEP_SIZE)
		if randf() < P_ROOM:
			make_room()
		walk_direction = random_dir()
	end_position = map_position
	tile_map.update_bitmask_region(Vector2(0,0), MAP_SIZE)
	tile_map.update_dirty_quadrants()
	tile_map.update()

func fill_map():
	for x in range(MAP_SIZE.x):
		for y in range(MAP_SIZE.y):
			tile_map.set_cell(x, y, tile_id_wall)

func walk_step():
	map_position += walk_direction
	tile_map.set_cell(map_position.x, map_position.y, tile_id_room)

func walk_steps(n_steps):
	for i in range(n_steps):
		walk_step()

func make_border():
	for x in range(MAP_SIZE.x):
		for y in range(MAP_SIZE.y):
			if not map_area.has_point(Vector2(x, y)):
				tile_map.set_cell(x, y, tile_id_border)

func make_room():
	var room_size = Vector2()
	room_size.x = MIN_ROOM_SIZE + randi() % (MAX_ROOM_SIZE - MIN_ROOM_SIZE)
	room_size.y = MIN_ROOM_SIZE + randi() % (MAX_ROOM_SIZE - MIN_ROOM_SIZE)
	var room_pos = (map_position - room_size / 2).floor()
	var room = Rect2(room_pos, room_size)
	for x in range(room.position.x, room.position.x + room.size.x):
		for y in range(room.position.y, room.position.y + room.size.y):
			tile_map.set_cell(x, y, tile_id_room)
	rooms.append(room)

func get_random_position(exclude_start=true, room_border=1):
	var rs = rooms.duplicate()
	if exclude_start:
		rs.pop_front()
	var r = rs[randi() % len(rs)]
	var randpos = Vector2()
	randpos.x = r.position.x + room_border + randi() % int(r.size.x - 2 * room_border)
	randpos.y = r.position.y + room_border + randi() % int(r.size.y - 2 * room_border)
	return randpos
