extends Control

@onready var h_box_container: HBoxContainer = $HBoxContainer
var myButtons

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	myButtons = h_box_container.get_children()
	myButtons[0].button_pressed = true

func setValue(val: int) -> void:
	var n = clamp(val,0,myButtons.size())

func getValue() -> int:
	for x in range(myButtons.size()):
		if myButtons[x].button_pressed == true:
			return x
	#return zero by default; this shoudln't really happend, but just in case
	return 0
