extends Node2D

@export var myCam:Camera2D
@export var custom_cursor:Texture2D
@export var custom_cursor_clicked: Texture2D
## mouse cursor
var hotspot = Vector2(60, 50)  # Adjust these values to set the tip of the cursor

func _ready() -> void:
	pass
	#SharedData.mouseIcon = self

func _process(_deltaTime: float) -> void:
	## mouse cursor effect
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		Input.set_custom_mouse_cursor(custom_cursor_clicked, Input.CURSOR_ARROW, hotspot)
	else:
		Input.set_custom_mouse_cursor(custom_cursor, Input.CURSOR_ARROW, hotspot)
