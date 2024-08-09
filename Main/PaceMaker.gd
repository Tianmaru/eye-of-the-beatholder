extends Node2D

signal beat
signal measure
signal beat_start
signal beat_end

# Beats Per Minute
export(float) var BPM := 120.0 setget set_bpm
export(float) var TOLERANCE_HIT := 0.3
export(float) var TOLERANCE_PERFECT := 0.15
export(int) var BEATS_PER_MEASURE := 4

# Seconds Per Beat
var SPB : float

var play_time : float = 0
var beats : int = 0
var finished_beats : int = 0
var measures : int = 0

onready var audio_player = $AudioStreamPlayer
onready var beat_timer = $BeatTimer
onready var beat_start_timer = $BeatStartTimer
onready var beat_end_timer = $BeatEndTimer

func _ready():
	pass

func start(measure_offset):
	beats = 0
	measures = 0
	SPB = 60.0 / BPM
	var t_offset = measure_offset * SPB * BEATS_PER_MEASURE
	beat_timer.start(t_offset)
	var tol = SPB * TOLERANCE_HIT
	beat_start_timer.start(t_offset - tol)
	yield(beat_timer, "timeout")
	audio_player.play()

func time_to_beats(t):
	return floor(t / SPB)

func get_play_time() -> float:
	var t = audio_player.get_playback_position() # estimated playback position
	t += AudioServer.get_time_since_last_mix() # time since last chunk update
	t -= AudioServer.get_output_latency() # time until sound is actually hearable
	return t

func get_offset():
	var t = get_play_time()
	return fmod(t, SPB)

func is_on_beat() -> bool:
	if audio_player.playing and beat_end_timer.time_left > 0:
		return true
	return false

func get_feedback() -> String:
	var offset = get_offset()
	var hit_tol = TOLERANCE_HIT * SPB
	var perfect_tol = TOLERANCE_PERFECT * SPB
	if offset <= perfect_tol or SPB - perfect_tol <= offset:
		return "PERFECT!"
	if offset <= hit_tol:
		return "TOO LATE!"
	if SPB - hit_tol <= offset:
		return "TOO SOON!"
	return "MISSED"

func _on_BeatTimer_timeout():
	beats += 1
	emit_signal("beat")
	if beats % BEATS_PER_MEASURE == 0:
		measures += 1
		emit_signal("measure")
	var t = get_play_time()
	var offset = (beats - 1) * SPB - t
	beat_timer.start(SPB + offset)
	var tol = SPB * TOLERANCE_HIT
	beat_start_timer.start(SPB - tol + offset)

func _on_BeatStartTimer_timeout():
	emit_signal("beat_start")
	var tol = SPB * TOLERANCE_HIT
	beat_end_timer.start(2 * tol)

func _on_BeatEndTimer_timeout():
	print("beat_end")
	emit_signal("beat_end")
	finished_beats += 1

func set_bpm(value):
	BPM = value
	SPB = 60.0 / BPM

func set_song(song):
	audio_player.stop()
	audio_player.stream = song
