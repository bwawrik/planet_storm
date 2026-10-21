@tool
extends Sprite2D
# Rotation speed in degrees per second
@export var rotation_speed: float = 90.0 

func _process(delta: float) -> void:
	# delta ensures smooth, framerate-independent rotation
	rotation_degrees += rotation_speed * delta
