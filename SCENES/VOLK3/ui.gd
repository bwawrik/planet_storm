extends CanvasLayer

const MIN_DRAG_SIZE := 40.0

var _dragging := false
var _selection_box_started := false
var _start := Vector2.ZERO
var _end := Vector2.ZERO
var _box: Control

func _ready() -> void:
	_box = Control.new()
	_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	_box.draw.connect(_draw_box)
	add_child(_box)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_dragging = true
			_selection_box_started = false
			_start = event.position
			_end = event.position
		elif _dragging:
			_dragging = false
			_end = event.position
			_box.queue_redraw()
			_emit_area()
	elif event is InputEventMouseMotion and _dragging:
		_end = event.position
		var screen := _screen_rect()
		if not _selection_box_started and (screen.size.x >= MIN_DRAG_SIZE or screen.size.y >= MIN_DRAG_SIZE):
			_selection_box_started = true
			SignalBus.SelectionBoxStarted.emit()
		_box.queue_redraw()

func _screen_rect() -> Rect2:
	return Rect2(_start, Vector2.ZERO).expand(_end)

func _draw_box() -> void:
	if not _dragging:
		return
	var r := _screen_rect()
	_box.draw_rect(r, Color(0.3, 0.7, 1.0, 0.25), true)
	_box.draw_rect(r, Color(0.165, 0.552, 0.444, 0.8), false, 1.0)

func _emit_area() -> void:
	var screen := _screen_rect()
	if screen.size.x < MIN_DRAG_SIZE and screen.size.y < MIN_DRAG_SIZE:
		SignalBus.UnselectAll.emit()
		return
	var to_world := get_viewport().get_canvas_transform().affine_inverse()
	SignalBus.selectArea.emit(to_world * screen)
