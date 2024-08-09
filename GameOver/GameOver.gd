extends Control

onready var message_label = $VBoxContainer/Message
onready var title_label = $VBoxContainer/Title
onready var particles = $CPUParticles2D
onready var game_over_sfx = $GameOverSfx
onready var victory_sfx = $VictorySfx

# Called when the node enters the scene tree for the first time.
func _ready():
	if Global.victory:
		title_label.text = "Victory!"
		message_label.text = "You beat the Beatholder - ironic!"
		if Global.score >= 100:
			particles.emitting = true
		victory_sfx.play()
	else:
		title_label.text = "Game Over!"
		message_label.text = "You couldn't hold the beat..."
		particles.emitting = false
		game_over_sfx.play()

func _unhandled_input(event):
	if event.is_action_pressed("action"):
		Global.score = 0
		Global.level = 0
		Global.victory = false
		Global.player_hp = 3
		Global.player_power = 1
		get_tree().change_scene("res://Main/Main.tscn")
