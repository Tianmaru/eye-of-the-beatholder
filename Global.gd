extends Node

var victory = false
var score = 0
var level = 0
var player_hp = 3
var player_power = 1

const LEVEL_CONFIG = [
	{
		"name": "Lo-Forest",
		"boss": false,
		"tile_wall": "tree",
		"tile_border": "block",
		"tile_room": "room",
		"enemy": preload("res://Enemies/Watoto.tscn"),
		"n_enemies": 2,
		"bpm": 120,
		"song": preload("res://music/adventure_time_revision.ogg")
	},
	{
		"name": "Bluecano",
		"boss": false,
		"tile_wall": "fire",
		"tile_border": "block",
		"tile_room": "room",
		"enemy": preload("res://Enemies/Zuko.tscn"),
		"n_enemies": 3,
		"bpm": 90,
		"song": preload("res://music/A Conversation with Saul_extended.ogg")
	},
	{
		"name": "Doomtomb",
		"boss": false,
		"tile_wall": "grave",
		"tile_border": "block",
		"tile_room": "room",
		"enemy": preload("res://Enemies/Casper.tscn"),
		"n_enemies": 4,
		"bpm": 164,
		"song": preload("res://music/Orbital Colossus_0.ogg")
	},
	{
		"name": "Beathold",
		"boss": true,
		"tile_wall": "portal",
		"tile_border": "block",
		"tile_room": "room",
		"enemy": preload("res://Enemies/Beatholder.tscn"),
		"n_enemies": 1,
		"enemy_x": 15,
		"enemy_y": 5,
		"bpm": 140,
		"song": preload("res://music/Zander Noriega - Dragged Through Hellfire.ogg")
	},
]

func get_level_config():
	return LEVEL_CONFIG[level]

func next_level(player):
	level += 1
	player_hp = player.hp
	player_power = player.power
	if level < len(LEVEL_CONFIG):
		get_tree().reload_current_scene()
	else:
		victory = true
		game_over()

func game_over():
	get_tree().change_scene("res://GameOver/GameOver.tscn")
