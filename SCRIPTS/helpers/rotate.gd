@tool
extends Node3D

@export_category("Rotation Axes")
@export var do_rotate_x: bool = false
@export var do_rotate_y: bool = false
@export var do_rotate_z: bool = false

@export_category("Rotation Settings")
@export_range(-15.0, 15.0, 1.0) var rotation_speed: float = -2.0

func _process(delta: float) -> void:
	var amount := rotation_speed * delta

	if do_rotate_x:
		rotate_x(amount)

	if do_rotate_y:
		rotate_y(amount)

	if do_rotate_z:
		rotate_z(amount)
