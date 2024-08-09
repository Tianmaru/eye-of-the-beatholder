class_name TurnBeatAction
extends BeatAction

func _init(_owner).(_owner):
	action_name = "turn"
	icon = "res://icons/icon_turn.png"

func _execute(player, npcs):
	owner.rotate(1)
