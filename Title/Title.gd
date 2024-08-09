extends Node

func _unhandled_input(event):
	if event.is_action_pressed("action"):
		get_tree().change_scene("res://Main/Main.tscn")
