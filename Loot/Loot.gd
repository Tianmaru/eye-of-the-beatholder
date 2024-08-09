extends Area2D

export(int) var MIN_POINTS = 0
export(int) var MAX_POINTS = 0
export(int) var heal := 0
export(int) var dmg_up := 0

var points = 0
var map_position = Vector2()

func _ready():
	points = MIN_POINTS
	if MAX_POINTS > MIN_POINTS:
		points += randi() % (MAX_POINTS - MIN_POINTS)
