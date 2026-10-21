extends Node
class_name Counter

var min_value: int = 0
var max_value: int = 10
var step: int = 1
var repeat: bool = true

var current_value: int = 1:
	set(value):
		if value > max_value:
			current_value = min_value if repeat else max_value
		elif value < min_value:
			current_value = max_value if repeat else min_value
		else:
			current_value = value

func GetPosition():
	return current_value

# The Constructor method
func _init(p_min: int = 0, p_max: int = 10, p_step: int = 1, p_start: int = 1, p_repeat: bool = true) -> void:
	min_value = p_min
	max_value = p_max
	step = p_step
	repeat = p_repeat
	current_value = p_start # This triggers the setter to safely validate the starting value

func inc() -> void:
	current_value += step
			
func dec() -> void:
	current_value -= step
