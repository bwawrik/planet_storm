extends Node

var musicSwitchInterval = 30

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#SceneManager.call_deferred("change_scene", "Start Game")
	SceneManager.call_deferred("change_scene", "Main Menu")
	SharedData.musicManager.play_track(SharedData.musicTracks[randi_range(0,SharedData.musicTracks.size()-1)])
	SharedData.musicManager.set_volume(-30)
	#_resSet()

func _resSet():
	var screen_size = DisplayServer.screen_get_size()
	DisplayServer.window_set_size(screen_size)
	get_window().content_scale_size = screen_size


#func CycleMusic(_deltaTime:float) -> void:
#	musicSwitchInterval = musicSwitchInterval - _deltaTime
#	if musicSwitchInterval < 0:
#		musicSwitchInterval = 30
#		SharedData.musicManager.play_track(SharedData.musicLoops[randi_range(0,SharedData.musicLoops.size()-1)])
