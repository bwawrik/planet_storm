extends Node

class_name MusicManager

var current_track: AudioStreamPlayer
var next_track: AudioStreamPlayer
var tween: Tween

@export var fade_duration: float = 2.0
@export var music_enabled: bool = true
@export_range(-80, 0) var volume_db: float = -20:
	set(value):
		volume_db = value
		if current_track:
			current_track.volume_db = value
		if next_track:
			next_track.volume_db = value

func _ready():
	current_track = AudioStreamPlayer.new()
	next_track = AudioStreamPlayer.new()
	current_track.volume_db = -80
	next_track.volume_db = -80
	add_child(current_track)
	add_child(next_track)
	
	# Set initial volume
	current_track.volume_db = volume_db
	next_track.volume_db = volume_db
	
	# Connect finished signal to replay function
	current_track.finished.connect(_on_track_finished)
	next_track.finished.connect(_on_track_finished)

func play_track(stream: AudioStream):
	if not music_enabled:
		return
	
	if current_track.playing:
		transition_to(stream)
	else:
		current_track.stream = stream
		current_track.play()
		fade_in(current_track)

func transition_to(stream: AudioStream):
	next_track.stream = stream
	next_track.play()
	fade_in(next_track)
	fade_out(current_track)
	await get_tree().create_timer(fade_duration).timeout
	var temp = current_track
	current_track = next_track
	next_track = temp

func fade_in(player: AudioStreamPlayer):
	tween = create_tween()
	tween.tween_property(player, "volume_db", volume_db, fade_duration).from(-80)

func fade_out(player: AudioStreamPlayer):
	tween = create_tween()
	tween.tween_property(player, "volume_db", -80, fade_duration)
	await tween.finished
	player.stop()

func stop_music():
	fade_out(current_track)
	if next_track.playing:
		fade_out(next_track)

func set_music_enabled(enabled: bool):
	music_enabled = enabled
	if not music_enabled:
		stop_music()
	elif not current_track.playing and current_track.stream:
		current_track.play()

func set_volume(new_volume_db: float):
	volume_db = new_volume_db

func _on_track_finished():
	if music_enabled and current_track.stream:
		current_track.play()
