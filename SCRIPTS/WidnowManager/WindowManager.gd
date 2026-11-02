extends Control

func _ready() -> void:
	ConnectWindows()
	#SharedData.UINode = self
	SignalBus.connect_windows.connect(ConnectWindows)

func ConnectWindows():
	# Automatically find and listen to all windows inside this container
	for child in get_children():
		if child is GameWindow:
			child.window_focused.connect(_on_window_selected)
			
	# Start by focusing the first window
	if get_child_count() > 0 and get_child(0) is GameWindow:
		get_child(0).focus_window()
	

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

func _on_window_selected(_active_window: GameWindow) -> void:
	# Optional: Perform manager-level logic here (e.g., play audio cues)
	pass

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
