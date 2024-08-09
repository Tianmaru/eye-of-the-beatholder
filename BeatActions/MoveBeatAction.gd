class_name MoveBeatAction
extends BeatAction

func _init(_owner).(_owner):
	action_name = "move"
	icon = "res://icons/icon_move.png"

func _execute(player, npcs):
	var beatles = npcs.duplicate()
	beatles.append(player)
	owner.attack_move(owner.walk_direction, beatles)
