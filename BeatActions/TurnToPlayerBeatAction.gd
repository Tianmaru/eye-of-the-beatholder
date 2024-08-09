class_name TurnToPlayerBeatAction
extends BeatAction

func _init(_owner).(_owner):
	action_name = "turn to player"
	icon = "res://icons/icon_turn.png"

func _execute(player, npcs):
	var d = player.map_position - owner.map_position
	var a = rad2deg(d.angle()) + 45 + 90
	a = fmod(a, 360)
	var o = int(a / 90)
	owner.orientation = o
