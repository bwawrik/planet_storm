extends Sprite2D

const MAX_TIME := 0.3
var time_passed = 0.0
var holding := false

func _ready():
	SignalBus.SelectionBoxStarted.connect(_on_selection_box_started)
	_update_shader()

func _on_selection_box_started() -> void:
	holding = false
	time_passed = 0.0
	_update_shader()

func _process(delta):
	global_position = get_global_mouse_position()
	if holding:
		time_passed = minf(time_passed + delta, MAX_TIME)
	_update_shader()
	if time_passed == MAX_TIME:
		time_passed = 0
		holding = false
		SignalBus.CircleMenuVisible.emit(true, get_viewport().get_mouse_position())

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			holding = true
		else:
			holding = false
			time_passed = 0.0

# 1 second == 100% of the shader's "value"
func _update_shader():
	var mat := material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("value", time_passed / MAX_TIME)
