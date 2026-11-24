extends CanvasLayer

@export var unit_activity_panel: HToggleButtonGroup
@export var score_panel: Control 
@export var build_panel: BuildPanel

const MIN_DRAG_SIZE := 40.0

var _dragging := false
var _right_mouse_down := false
var _right_dragging := false
var _circle_menu_visible := false
var _right_press_position := Vector2.ZERO
var _right_last_tile := Vector2i.ZERO
var _selection_box_started := false
var _placing_totems := false
var _clearing_totems := false
var _totem_hold_pending := false
var _has_last_totem_tile := false
var _last_totem_tile := Vector2i.ZERO
var _start := Vector2.ZERO
var _end := Vector2.ZERO
var _box: Control

func _ready() -> void:
	SharedData.UINode = self
	SignalBus.CircleMenuVisible.connect(_on_circle_menu_visibility_changed)
	SignalBus.CircleMenuLeftMouse.connect(_on_circle_menu_left_mouse)
	_box = Control.new()
	_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	_box.draw.connect(_draw_box)
	add_child(_box)

func _process(_delta: float) -> void:
	var units_selected = SharedData.MAP.HasSelectedUnits()
	if unit_activity_panel.visible != units_selected:
		unit_activity_panel.visible = units_selected
		if units_selected == true:
			var units = SharedData.MAP.GetSelectedUnits()
			if units != null and units.size()>0:
				unit_activity_panel.SetValue(units[0].current_order)
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_dragging = true
			_selection_box_started = false
			_clearing_totems = _is_clear_selected()
			_totem_hold_pending = build_panel.recipe != null and not _clearing_totems and not SharedData.MAP.HasSelectedUnits()
			_placing_totems = false
			_has_last_totem_tile = false
			_start = event.position
			_end = event.position
			if _clearing_totems:
				_clear_totems_at(event.position)
		elif _dragging:
			var hold_was_pending := _totem_hold_pending
			_totem_hold_pending = false
			if _clearing_totems:
				_clear_totems_at(event.position)
			elif _placing_totems:
				_place_totem_at(event.position)
			_dragging = false
			_end = event.position
			_box.queue_redraw()
			if not _clearing_totems and not _placing_totems and (not hold_was_pending or event.position.distance_to(_start) > 5.0):
				_emit_area()
			_placing_totems = false
			_clearing_totems = false
	elif event is InputEventMouseMotion:
		if _dragging:
			_end = event.position
			if _clearing_totems:
				_clear_totems_at(event.position)
				_box.queue_redraw()
			elif _placing_totems:
				_place_totem_at(event.position)
				_box.queue_redraw()
				return
			else:
				var screen := _screen_rect()
				if not _selection_box_started and (screen.size.x >= MIN_DRAG_SIZE or screen.size.y >= MIN_DRAG_SIZE):
					_selection_box_started = true
					SignalBus.SelectionBoxStarted.emit()
				_box.queue_redraw()
		if _right_mouse_down:
			_update_right_mouse_drag(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			_right_mouse_down = true
			_right_dragging = false
			_right_press_position = event.position
		elif _right_mouse_down:
			_right_mouse_down = false
			_right_dragging = false

	if event.is_action_pressed("ShiftRightClick", true):
		build_panel.ClearRecipe()
		SignalBus.RightClickOnMap.emit(event)
	elif event.is_action_pressed("RightClick", true):
		build_panel.ClearRecipe()
		SignalBus.RightClickOnMap.emit(event)
		SignalBus.UnselectAll.emit.call_deferred()

func _screen_rect() -> Rect2:
	return Rect2(_start, Vector2.ZERO).expand(_end)

func _draw_box() -> void:
	if not _dragging or _placing_totems or _clearing_totems:
		return
	var r := _screen_rect()
	_box.draw_rect(r, Color(0.3, 0.7, 1.0, 0.25), true)
	_box.draw_rect(r, Color(0.165, 0.552, 0.444, 0.8), false, 1.0)

func _place_totem_at(viewport_pos: Vector2) -> void:
	var tile := _tile_at(viewport_pos)
	if _has_last_totem_tile and tile == _last_totem_tile:
		return
	_last_totem_tile = tile
	_has_last_totem_tile = true
	SignalBus.CircleMenuLeftMouse.emit(false, viewport_pos)

func _is_clear_selected() -> bool:
	return build_panel.recipe != null and build_panel.recipe.name == &"CLEAR"

func _clear_totems_at(viewport_pos: Vector2) -> void:
	var tile := _tile_at(viewport_pos)
	if _has_last_totem_tile:
		_remove_totems_between(_last_totem_tile, tile)
	else:
		_remove_totems_between(tile, tile)
	_last_totem_tile = tile
	_has_last_totem_tile = true

func _on_circle_menu_left_mouse(hold_completed: bool, viewport_pos: Vector2) -> void:
	if not hold_completed or not _totem_hold_pending or not _dragging:
		return
	_totem_hold_pending = false
	_placing_totems = true
	_last_totem_tile = _tile_at(viewport_pos)
	_has_last_totem_tile = true

func _update_right_mouse_drag(viewport_pos: Vector2) -> void:
	if _circle_menu_visible:
		return
	if not _right_dragging:
		if viewport_pos.distance_to(_right_press_position) < MIN_DRAG_SIZE:
			return
		_right_dragging = true
		SignalBus.CircleMenuVisible.emit(false, Vector2.ZERO)

func _on_circle_menu_visibility_changed(menu_visible: bool, _viewport_pos: Vector2) -> void:
	_circle_menu_visible = menu_visible
	if menu_visible:
		_right_mouse_down = false
		_right_dragging = false

func _tile_at(viewport_pos: Vector2) -> Vector2i:
	var terrain: TileMapLayer = SharedData.MAP.terrainlayer
	return terrain.local_to_map(terrain.get_global_transform_with_canvas().affine_inverse() * viewport_pos)

func _remove_totems_between(from_tile: Vector2i, to_tile: Vector2i) -> void:
	var x := from_tile.x
	var y := from_tile.y
	var dx := absi(to_tile.x - from_tile.x)
	var sx := 1 if from_tile.x < to_tile.x else -1
	var dy := -absi(to_tile.y - from_tile.y)
	var sy := 1 if from_tile.y < to_tile.y else -1
	var error := dx + dy

	while true:
		var totem := SharedData.MAP.FindTotemAt(Vector2i(x, y)) as Totem
		if totem and not totem.is_queued_for_deletion():
			totem.queue_free()
		if x == to_tile.x and y == to_tile.y:
			break
		var doubled_error := error * 2
		if doubled_error >= dy:
			error += dy
			x += sx
		if doubled_error <= dx:
			error += dx
			y += sy

func _emit_area() -> void:
	var screen := _screen_rect()
	if screen.size.x < MIN_DRAG_SIZE and screen.size.y < MIN_DRAG_SIZE:
		SignalBus.UnselectAll.emit()
		return
	var to_world := get_viewport().get_canvas_transform().affine_inverse()
	SignalBus.selectArea.emit(to_world * screen)
