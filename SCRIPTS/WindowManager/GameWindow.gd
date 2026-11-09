extends Control
class_name GameWindow

signal window_focused(window: GameWindow)

@export var title_label: Label 
@export var title_bar: Control 
@export var default_focus_node: Control 
@export var close_button: Label
@onready var content_area = $PanelContainer/VBoxContainer/ContentArea

@export var window_title: String = "New Window":
	set(value):
		window_title = value
		if is_node_ready():
			title_label.text = value
			
@export var canClose : bool = false

var is_active: bool = false
var is_dragging_with_controller: bool = false
var is_dragging_with_mouse: bool = false
var mouse_drag_offset: Vector2 = Vector2.ZERO
var controller_drag_speed: float = 400.0 

func _ready() -> void:
	title_label.text = window_title
	title_bar.gui_input.connect(_on_title_bar_gui_input)
	title_bar.mouse_filter = Control.MOUSE_FILTER_STOP
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	if close_button:
		if close_button != null:
			close_button.gui_input.connect(_on_close_button_gui_input)
	
	# Connect to the global viewport focus signal
	get_viewport().gui_focus_changed.connect(_on_gui_focus_changed)

func _process(delta: float) -> void:
	# If the user holds down a drag button (e.g., Joypad Button A/Cross) while active, move it
	if is_active and is_dragging_with_controller:
		var move_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		_move_window_to(global_position + move_dir * controller_drag_speed * delta)
	
	if is_active and Input.is_action_just_pressed("ui_close_dialog"):
		# Close the window if the close dialog action is triggered
		if canClose == true:
			queue_free()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		var ended_mouse_drag := is_dragging_with_mouse
		is_dragging_with_mouse = false
		if ended_mouse_drag:
			Activate_window()
			focus_window()

	if event is InputEventMouseMotion and is_dragging_with_mouse:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			_move_window_to(get_global_mouse_position() - mouse_drag_offset)
		else:
			is_dragging_with_mouse = false

	if not is_active:
		return
		
	# Example shortcut: Toggle controller window-dragging mode using a joypad button
	if event.is_action_pressed("ui_accept"): # Change to a custom action like "window_drag" if preferred
		is_dragging_with_controller = true
	elif event.is_action_released("ui_accept"):
		is_dragging_with_controller = false

func _on_title_bar_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			Activate_window()
			is_dragging_with_mouse = true
			is_dragging_with_controller = false
			mouse_drag_offset = get_global_mouse_position() - global_position
			focus_window()
			accept_event()
		else:
			is_dragging_with_mouse = false
			Activate_window()
			focus_window()
			accept_event()

func _on_close_button_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		queue_free()

func _move_window_to(target_global_position: Vector2) -> void:
	var viewport_size := get_viewport_rect().size
	var max_x := maxf(0.0, viewport_size.x - size.x)
	var max_y := maxf(0.0, viewport_size.y - size.y)
	global_position = Vector2(target_global_position.x, target_global_position.y)


func focus_window() -> void:
	var focus_target := _find_first_focusable_control(default_focus_node)
	if focus_target:
		focus_target.grab_focus()
	elif default_focus_node and default_focus_node.focus_mode != Control.FOCUS_NONE:
		default_focus_node.grab_focus()

func _find_first_focusable_control(root: Node) -> Control:
	if root == null:
		return null

	for child in root.get_children():
		if child is Control:
			var control := child as Control
			if control.visible and control.focus_mode != Control.FOCUS_NONE:
				return control

		var nested_focus_target := _find_first_focusable_control(child)
		if nested_focus_target:
			return nested_focus_target

	return null

func _on_gui_focus_changed(node: Control) -> void:
	# Check if the newly focused node belongs to this specific window
	if node and is_ancestor_of(node):
		if not is_active:
			Activate_window()
	else:
		if is_active and not is_dragging_with_mouse:
			_deactivate_window()

func Activate_window() -> void:
	is_active = true
	# Bring this control node to the front visual layer
	get_parent().move_child(self, get_parent().get_child_count() - 1)
	window_focused.emit(self)
	modulate = Color(1.0, 1.0, 1.0, 1.0) # Full brightness

func _deactivate_window() -> void:
	is_active = false
	is_dragging_with_controller = false
	is_dragging_with_mouse = false
	modulate = Color(0.549, 0.549, 0.561, 0.373) # Dim out inactive window
