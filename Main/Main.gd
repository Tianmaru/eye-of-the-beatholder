extends Node2D

onready var player = $Player
onready var exit = $Exit
onready var lvl_gen = $LevelGenerator
onready var tile_map = $TileMap
onready var shadow_map = $ShadowMap
onready var enemies_node = $Enemies
onready var items_node = $Items
onready var pace_maker = $PaceMaker
onready var feedback_label = $UILayer/FeedbackLabel
onready var feedback_anim = $UILayer/FeedbackAnimationPlayer
onready var action_queue = $UILayer/ActionQueue
onready var level_name_label = $UILayer/LevelName
onready var level_num_label = $UILayer/LevelNumber
onready var hp_label = $UILayer/HpInfo/HpLabel
onready var power_label = $UILayer/PowerInfo/PowerLabel
onready var gold_label = $UILayer/GoldInfo/GoldLabel


var items = {
	"gold": preload("res://Loot/Gold.tscn"),
	"potion": preload("res://Loot/Potion.tscn"),
	"sword": preload("res://Loot/Sword.tscn")
}

var loot = []

var beat_ready = true
var npcs_moved = false
var enemies = []
var start_positions = []

# Called when the node enters the scene tree for the first time.
func _ready():
	var lvl_cfg = Global.get_level_config()
	lvl_gen.TILE_NAME_WALL = lvl_cfg.tile_wall
	lvl_gen.TILE_NAME_BORDER = lvl_cfg.tile_border
	lvl_gen.TILE_NAME_ROOM = lvl_cfg.tile_room
	tile_map.wall_name = lvl_cfg.tile_wall
	tile_map.border_name = lvl_cfg.tile_border
	tile_map.room_name = lvl_cfg.tile_room
	pace_maker.set_bpm(lvl_cfg.bpm)
	pace_maker.set_song(lvl_cfg.song)
	player.hp = Global.player_hp
	player.power = Global.player_power
	if not lvl_cfg.boss:
		lvl_gen.generate_level()
		player.global_position = tile_map.map_to_world(get_empty_position())
		player.update_map_position()
		exit.global_position = tile_map.map_to_world(get_empty_position())
		update_shadows()
		for i in range(lvl_cfg.n_enemies):
			var enemy = lvl_cfg.enemy.instance()
			enemy.map = tile_map
			enemy.global_position = tile_map.map_to_world(get_empty_position())
			enemy.update_map_position()
			enemy.connect("knocked_out", self, "spawn_loot", [enemy])
			enemies_node.add_child(enemy)
	else:
		shadow_map.clear()
		player.update_map_position()
		exit.visible = false
		var enemy = lvl_cfg.enemy.instance()
		enemy.map = tile_map
		var enemy_pos = Vector2(lvl_cfg.enemy_x, lvl_cfg.enemy_y)
		enemy.global_position = tile_map.map_to_world(enemy_pos)
		enemy.update_map_position()
		enemy.connect("knocked_out", self, "spawn_exit", [enemy])
		enemies_node.add_child(enemy)
	action_queue.fill_queue(player.beat_actions)
	update_ui()
	pace_maker.start(1)

func _unhandled_input(event):
	if beat_ready and event.is_action_pressed("action"):
		beat_ready = false
		give_feedback(pace_maker.get_feedback())
		if pace_maker.is_on_beat():
			var ba = get_beat_action(player.beat_actions)
			ba.execute(player, enemies_node.get_children())
			check_loot()
			update_shadows()
			move_npcs()
			update_ui()

func move_npcs():
	var npcs = get_tree().get_nodes_in_group("npc")
	for npc in npcs:
		var ba = get_beat_action(npc.beat_actions)
		ba.execute(player, enemies_node.get_children())
	for p in get_tree().get_nodes_in_group("projectile"):
		var ba = get_beat_action(p.beat_actions)
		ba.execute(player, enemies_node.get_children())
	npcs_moved = true
	update_ui()

func get_beat_action(beat_actions):
	var ba_id = pace_maker.finished_beats % len(beat_actions)
	return beat_actions[ba_id]

func _on_PaceMaker_beat():
	action_queue.move_queue(pace_maker.beats)
	if not beat_ready and not npcs_moved:
		move_npcs()

func _on_PaceMaker_measure():
	pass # Replace with function body.

func _on_PaceMaker_beat_end():
	if not npcs_moved:
		give_feedback("missed")
		move_npcs()
	beat_ready = true
	npcs_moved = false

func _on_Exit_area_entered(area):
	exit.disconnect("area_entered", self, "_on_Exit_area_entered")
	yield(get_tree().create_timer(0.25), "timeout")
	Global.next_level(player)

func spawn_loot(enemy):
	var p = randf()
	var item = items.gold
	if 0.4 <= p and p < 0.7:
		item = items.potion
	elif 0.7 <= p:
		item = items.sword
	item = item.instance()
	item.map_position = enemy.map_position
	item.global_position = tile_map.map_to_world(enemy.map_position)
	items_node.add_child(item)
	loot.append(item)

func check_loot():
	var loot_left = []
	for item in loot:
		if player.map_position.is_equal_approx(item.map_position):
			player.hp += item.heal
			player.power += item.dmg_up
			Global.score += item.points
			item.call_deferred("queue_free")
		else:
			loot_left.append(item)
	loot = loot_left

func get_empty_position():
	var position_found = false
	var random_pos = Vector2()
	while not position_found:
		position_found = true
		random_pos = lvl_gen.get_random_position()
		for p in start_positions:
			if random_pos.is_equal_approx(p):
				position_found = false
	start_positions.append(random_pos)
	return random_pos

func update_shadows():
	var pos = player.map_position
	for x in range(pos.x - 3, pos.x + 3):
		for y in range(pos.y - 3, pos.y + 3):
			shadow_map.set_cell(x, y, -1)

func update_ui():
	gold_label.text = str(Global.score)
	power_label.text = str(player.power)
	hp_label.text = str(player.hp)
	level_num_label.text = "Level %s" % (Global.level + 1)
	level_name_label.text = Global.get_level_config()["name"]

func _on_Player_knocked_out():
	Global.game_over()

func _on_AudioStreamPlayer_finished():
	Global.game_over()

func spawn_exit(enemy):
	exit.global_position = tile_map.map_to_world(enemy.map_position)
	exit.visible = true

func give_feedback(msg):
	feedback_label.text = msg
	feedback_anim.stop()
	feedback_anim.play("give_feedback")
