class_name ProjectileBeatAction
extends BeatAction

func _init(_owner).(_owner):
	action_name = "projectile move"
	icon = "res://icons/icon_move.png"

func _execute(player, npcs):
	var beatles = npcs.duplicate()
	beatles.append(player)
	if owner.can_attack(owner.walk_direction, [player]):
		owner.attack_move(owner.walk_direction, [player])
		owner.map_position = player.map_position
		owner.call_deferred("queue_free")
	elif owner.can_move(owner.walk_direction, beatles):
		owner.move(owner.walk_direction)
	else:
		owner.call_deferred("queue_free")
