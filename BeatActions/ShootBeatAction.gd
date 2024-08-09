class_name ShootBeatAction
extends BeatAction

var projectile_scene = preload("res://Enemies/MrBeam.tscn")

func _init(_owner).(_owner):
	action_name = "shoot projectile"
	icon = "res://icons/icon_move.png"

func _execute(player, npcs):
	var projectile = projectile_scene.instance()
	projectile.map_position = owner.map_position
	projectile.map = owner.map
	owner.get_parent().add_child(projectile)
	projectile.global_position = owner.global_position
	projectile.orientation = owner.orientation
