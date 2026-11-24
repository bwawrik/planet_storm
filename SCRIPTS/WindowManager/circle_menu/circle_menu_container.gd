@tool
extends Control

const CircleMenuIcon = preload("res://SCRIPTS/WindowManager/circle_menu/texture_rect.gd")
const QUICK_CLICK_MAX_MSEC := 300
var _scale_tween: Tween
var _left_press_started_at_msec := -1

@export var radius = 150:
	set (value):
		radius = value
		_refresh()

func _refresh(_child = null):
	var icons: Array[CircleMenuIcon] = []
	for child in get_children():
		if child is CircleMenuIcon:
			icons.append(child)
	if icons.is_empty():
		return

	var spacing = TAU / icons.size()
	for index in icons.size():
		var child = icons[index]
		var angle = spacing * index - PI / 2
		var target_direction = Vector2(radius, 0).rotated(angle)
		child.position = target_direction - child.size / 2
		child.focus_next = child.get_path_to(icons[(index + 1) % icons.size()])
		child.focus_previous = child.get_path_to(icons[(index + icons.size() - 1) % icons.size()])
		if not Engine.is_editor_hint() and not child.selected.is_connected(_select_item):
			child.selected.connect(_select_item)
		

func _ready() -> void:
	if not Engine.is_editor_hint():
		SignalBus.CircleMenuVisible.connect(_on_visibility_changed)
		#SignalBus.SelectionBoxStarted.connect(hide)
		SignalBus.SelectionBoxStarted.connect(_Hide)
		visibility_changed.connect(_on_tree_visibility_changed)
	child_entered_tree.connect(_refresh)
	child_exiting_tree.connect(_on_child_exited)
	SignalBus.CircleMenuLeftMouse.connect(PlaceTotemSelected)
	
	_refresh()
	_Hide()
	if not Engine.is_editor_hint():
		_on_tree_visibility_changed()


func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
#	if not is_visible_in_tree():		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
#			if event.pressed:
#				_left_press_started_at_msec = Time.get_ticks_msec()
#			elif _left_press_started_at_msec >= 0:
#				var press_duration_msec := Time.get_ticks_msec() - _left_press_started_at_msec
#				_left_press_started_at_msec = -1
#				if press_duration_msec < QUICK_CLICK_MAX_MSEC:
#					PlaceTotemSelected(event)
#		return
	if event is InputEventMouseMotion:
		_focus_nearest_icon(event.position)
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_Hide()
		elif event.button_index == MOUSE_BUTTON_LEFT and not _is_over_icon(event.position):
			_Hide()

## function needed to populate the build_panel
func _select_item(itm: ItemRecipe) -> void:
	SignalBus.BuildRecipeSelected.emit(itm)
	_Hide()




func PlaceTotemSelected(menu_visible: bool, viewport_pos: Vector2):

	# don't place totems when units are seleted
	if SharedData.MAP.HasSelectedUnits() == true: return
	if SharedData.UINode.build_panel.recipe == null: return
	print ("placing")
	## check if walkable
	var terrain: TileMapLayer = SharedData.MAP.terrainlayer
	var tile := terrain.local_to_map(terrain.get_global_transform_with_canvas().affine_inverse() * viewport_pos)
	if not SharedData.MAP.IsWalkable(tile):
		return
	if SharedData.MAP.FindTotemAt(tile) != null:
		return
	var vs := SharedData.effects[1].instantiate() as Totem
	var effect_node: Node2D = SharedData.MAP.effectNode
	var snapped_viewport_position := terrain.get_global_transform_with_canvas() * terrain.map_to_local(tile)
	var totem_position := effect_node.get_global_transform_with_canvas().affine_inverse() * snapped_viewport_position
	vs.tile_position = tile
	effect_node.add_child(vs)
	vs.displayTotem(totem_position, SharedData.UINode.build_panel.recipe)
	



func _Hide() -> void:
	hide()
	SignalBus.CircleMenuVisible.emit(false, Vector2.ZERO)




func _on_visibility_changed(menu_visible: bool, viewport_pos: Vector2) -> void:
	if menu_visible:
		global_position = get_canvas_transform().affine_inverse() * viewport_pos
	visible = menu_visible
	if menu_visible and is_visible_in_tree():
		_focus_nearest_icon(viewport_pos)




func _on_tree_visibility_changed() -> void:
	if _scale_tween and _scale_tween.is_valid():
		_scale_tween.kill()
	scale = Vector2(0.1, 0.1)
	if is_visible_in_tree():
		SharedData.PlaySound(SharedData.soundEffects[5])
		_scale_tween = create_tween()
		_scale_tween.tween_property(self, "scale", Vector2.ONE, 0.1)
		_focus_nearest_icon(get_viewport().get_mouse_position())

func _focus_nearest_icon(viewport_pos: Vector2) -> void:
	var nearest: CircleMenuIcon
	var nearest_distance := INF
	for child in get_children():
		if child is CircleMenuIcon and child.is_visible_in_tree():
			var center: Vector2 = child.get_global_transform_with_canvas() * (child.size / 2)
			var distance := center.distance_squared_to(viewport_pos)
			if distance < nearest_distance:
				nearest = child
				nearest_distance = distance
	if nearest and not nearest.has_focus():
		nearest.grab_focus()

func _is_over_icon(viewport_pos: Vector2) -> bool:
	for child in get_children():
		if child is CircleMenuIcon and child.is_visible_in_tree():
			var local_pos: Vector2 = child.get_global_transform_with_canvas().affine_inverse() * viewport_pos
			if Rect2(Vector2.ZERO, child.size).has_point(local_pos):
				return true
	return false

func _on_child_exited(_node):
	await get_tree().process_frame
	_refresh()
