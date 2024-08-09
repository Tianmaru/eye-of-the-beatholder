class_name RandomTurnBeatAction
extends BeatAction

func _init(_owner).(_owner):
	action_name = "random turn"
	icon = "res://icons/icon_turn.png"

func _execute(player, npcs):
	owner.rotate(randi() % 4)
