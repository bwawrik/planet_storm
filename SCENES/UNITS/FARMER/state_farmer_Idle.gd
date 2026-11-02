## Base class for all states
class_name StateFarmerIdle
extends State

var ponderTimer: = 2

func enter(_previous_state_path: StringName, _data := {}) -> void:
	super.enter(_previous_state_path, _data)
	ponderTimer = 2

func _process(delta: float) -> void:
	
	pass
