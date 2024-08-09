class_name AlignBeatAction
extends BeatAction

func _init(_owner).(_owner):
	action_name = "align"
	icon = "res://icons/icon_move.png"

func _execute(player, npcs):
	var d = player.map_position - owner.map_position
	var align_dir = Vector2.ONE - owner.walk_direction.abs()
	var move_dir = Vector2()
	if align_dir.x > 0:
		move_dir.x = sign(d.x)
	else:
		move_dir.y = sign(d.y)
	owner.attack_move(move_dir, [player] + npcs)
