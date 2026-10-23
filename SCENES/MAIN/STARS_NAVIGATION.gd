
extends Node2D

@export var base_size: float = 20.0
@export var pulse_percent: float = 0.30         # ±30% pulsation
@export var pulse_frequency: float = 1.0        # Hz

@export var box: Sprite2D
@export var selected_box: Sprite2D

@export var planetViewRoot: Control

var t := 0.0
var closest_node: Sprite2D = null

func _ready() -> void:
	SignalBus.connect("StarSelected", StarSelected)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		if selected_box != null:
			selected_box.visible = false


func _process(delta: float) -> void:
	t += delta
	_update_closest_node()
	_draw()

func _update_closest_node() -> void:
	var mouse_pos := get_global_mouse_position()
	var best_dist := INF
	closest_node = null

	for child in get_children():
		var pos: Vector2 = (child as Node2D).global_position
		var dist := pos.distance_to(mouse_pos)
		if dist < best_dist:
			best_dist = dist
			closest_node = child

func _draw() -> void:
	if closest_node == null:
		return

	# Pulsating size: s(t) = 1 + A * sin(2π f t)
	var scale := 0.3 + pulse_percent * sin(TAU * pulse_frequency * t)
	var size := base_size * scale
	var half := size * 0.5

	var center := closest_node.global_position
	
	box.position = center
	box.scale = Vector2(scale, scale)
	
func StarSelected(planets: Array[PLANET]):
	SignalBus.emit_signal("UpdatePlanets", planets)
	selected_box.visible = true
	selected_box.position = closest_node.global_position
