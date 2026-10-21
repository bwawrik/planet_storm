extends Control

func _ready() -> void:
	ConnectWindows()
	SharedData.UINode = self
	SignalBus.connect_windows.connect(_on_connect_windows_requested)
	
	# Catch windows as they enter the tree, before their own _ready activates them
	child_entered_tree.connect(_on_child_entered_tree)
	
	# Focus the first window once, at startup only
	if get_child_count() > 0 and get_child(0) is GameWindow:
		get_child(0).focus_window()

func _on_connect_windows_requested() -> void:
	ConnectWindows()

func _on_child_entered_tree(child: Node) -> void:
	if child is GameWindow and not child.window_focused.is_connected(_on_window_selected):
		child.window_focused.connect(_on_window_selected)

func ConnectWindows():
	# Automatically find and listen to all windows inside this container
	for child in get_children():
		if child is GameWindow and not child.window_focused.is_connected(_on_window_selected):
			child.window_focused.connect(_on_window_selected)
	

func _input(event: InputEvent) -> void:
	# Switch windows only on explicit shoulder/page key inputs.
	# This avoids conflicts when ui_page_* actions are also mapped to directional navigation.
	if event is InputEventJoypadButton and event.pressed:
		if event.button_index == JOY_BUTTON_RIGHT_SHOULDER:
			_cycle_window(1)
			get_viewport().set_input_as_handled()
			return
		elif event.button_index == JOY_BUTTON_LEFT_SHOULDER:
			_cycle_window(-1)
			get_viewport().set_input_as_handled()
			return

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_PAGEDOWN:
			_cycle_window(1)
			get_viewport().set_input_as_handled()
			return
		elif event.keycode == KEY_PAGEUP:
			_cycle_window(-1)
			get_viewport().set_input_as_handled()
			return

func _on_window_selected(active_window: GameWindow) -> void:
	# Ensure only one window is active at a time, regardless of how it got activated
	for child in get_children():
		if child is GameWindow and child != active_window and child.is_active and not child.is_dragging_with_mouse:
			child._deactivate_window()

func _cycle_window(direction: int) -> void:
	var windows: Array[GameWindow] = []
	var current_index := -1
	
	for child in get_children():
		if child is GameWindow:
			windows.append(child)
			if child.is_active:
				current_index = windows.size() - 1
				
	if windows.is_empty():
		return
		
	# Calculate the next window index with wrapping boundaries
	var next_index = (current_index + direction) % windows.size()
	if next_index < 0:
		next_index = windows.size() - 1
		
	windows[next_index].focus_window()
