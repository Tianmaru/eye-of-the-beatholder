class_name Beatle
extends Area2D

signal knocked_out

export(float) var MOVE_DURATION := 0.25
export(NodePath) var map_path
export(int) var MAX_HP := 3
export(int) var power := 1
export(Array, Resource) var _beat_actions

var hp : int = 0 setget set_hp

var map
var map_position : Vector2

var orientation = 0 setget set_orientation
var walk_direction := Vector2.UP
var beat_actions : Array

var DIRECTIONS := [
	Vector2.UP,
	Vector2.RIGHT,
	Vector2.DOWN,
	Vector2.LEFT,
]

onready var sprite = $Sprite
onready var hp_bar = $HpBar

# Called when the node enters the scene tree for the first time.
func _ready():
	hp = MAX_HP
	if map_path:
		map = get_node(map_path) as Map
	beat_actions = []
	for ba in _beat_actions:
		beat_actions.append(ba.new(self))

func map_to_world(map_pos):
	return map.map_to_world(map_pos)

func can_attack(direction, beatles):
	var new_map_pos = map_position + direction
	for b in beatles:
		if b == self:
			continue
		if new_map_pos.is_equal_approx(b.map_position):
			if "player" in get_groups() or "player" in b.get_groups():
				return b

func can_move(direction, beatles) -> bool:
	var new_map_pos = map_position + direction
	if not map.is_cell_walkable(new_map_pos):
		return false
	for b in beatles:
		if b == self:
			continue
		if new_map_pos.is_equal_approx(b.map_position):
			return false
	return true

func attack(target):
	target.take_damage(power)

func attack_move(direction, beatles):
	if can_move(direction, beatles):
		move(direction)
	else:
		var target = can_attack(direction, beatles)
		if target:
			attack(target)

func move(direction) -> bool:
	map_position = map_position + direction
	update_world_position()
	return true

func rotate(rot_dir):
	self.orientation += rot_dir

func set_orientation(value):
	orientation = value % len(DIRECTIONS)
	sprite.rotation_degrees = orientation * 90
	walk_direction = DIRECTIONS[orientation]

func update_world_position():
	var new_world_pos = map.map_to_world(map_position)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", new_world_pos, MOVE_DURATION)

func update_map_position():
	map_position = map.world_to_map(position)

func take_damage(dmg):
	print("took damage", dmg)
	self.hp -= dmg

func set_hp(value):
	hp = clamp(value, 0, MAX_HP)
	hp_bar.rect_size.x = float(hp) / MAX_HP * 8
	if hp <= 0:
		get_knocked_out()

func get_knocked_out():
	emit_signal("knocked_out")
	call_deferred("queue_free")
