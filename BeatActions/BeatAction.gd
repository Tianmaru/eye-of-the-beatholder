class_name BeatAction
extends Reference

var action_name
var owner
var icon

func _init(_owner):
	owner = _owner

func execute(player, npcs):
	_execute(player, npcs)

func _execute(player, npcs):
	pass
