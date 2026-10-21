#extends NinePatchRect
extends Panel

@export var tipText: RichTextLabel

signal text_changed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tipText.text = ""
	#Connect the text_changed signal
	connect("text_changed",_on_text_changed)
	#Adjust size initially
	_on_text_changed()

func SetText(s) -> void:
	tipText.text = s
	emit_signal("text_changed")
	#_on_text_changed()

func GetSize() -> Vector2:
	return $".".size

func _on_text_changed():
	# Get text size dynamically
	var text_width = tipText.get_content_width()
	var text_height = tipText.get_minimum_size().y
	# Add padding
	var padding = Vector2(40, 40)  # Adjust padding as needed
	# Adjust size correctly
	size = Vector2(text_width, text_height) + padding
