class_name MoveRightBeatAction
extends BeatAction

func _init(_owner).(_owner):
	action_name = "move left"
	icon = "res://icons/icon_move.png"

func _execute(player, npcs):
	var beatles = npcs.duplicate()
	beatles.append(player)
	owner.attack_move(Vector2.RIGHT, beatles)
