extends Sprite2D

const MAX_TIME := 0.3
const DRAG_THRESHOLD := 5.0
var time_passed = 0.0
var holding := false
var holding_button := MOUSE_BUTTON_NONE
var left_press_position := Vector2.ZERO

func _ready():
	SignalBus.SelectionBoxStarted.connect(_on_selection_box_started)
	_update_shader()

func _on_selection_box_started() -> void:
	holding = false
	holding_button = MOUSE_BUTTON_NONE
	time_passed = 0.0
	_update_shader()

func _process(delta):
	global_position = get_global_mouse_position()
	if holding and holding_button == MOUSE_BUTTON_LEFT and get_viewport().get_mouse_position().distance_to(left_press_position) > DRAG_THRESHOLD:
		holding = false
		time_passed = 0.0
	if holding:
		time_passed = minf(time_passed + delta, MAX_TIME)
	_update_shader()
	if time_passed == MAX_TIME:
		var completed_button := holding_button
		time_passed = 0
		holding = false
		holding_button = MOUSE_BUTTON_NONE
		if completed_button == MOUSE_BUTTON_RIGHT:
			SignalBus.CircleMenuVisible.emit(true, get_viewport().get_mouse_position())
		elif completed_button == MOUSE_BUTTON_LEFT:
			SignalBus.CircleMenuLeftMouse.emit(true, get_viewport().get_mouse_position())

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed and not holding:
				holding = true
				holding_button = MOUSE_BUTTON_RIGHT
			elif not event.pressed and holding_button == MOUSE_BUTTON_RIGHT:
				holding = false
				holding_button = MOUSE_BUTTON_NONE
				time_passed = 0.0
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and not holding:
				holding = true
				holding_button = MOUSE_BUTTON_LEFT
				left_press_position = get_viewport().get_mouse_position()
			elif not event.pressed and holding_button == MOUSE_BUTTON_LEFT:
				holding = false
				holding_button = MOUSE_BUTTON_NONE
				time_passed = 0.0
				SignalBus.CircleMenuLeftMouse.emit(false, get_viewport().get_mouse_position())

# 1 second == 100% of the shader's "value"
func _update_shader():
	var mat := material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("value", time_passed / MAX_TIME)
