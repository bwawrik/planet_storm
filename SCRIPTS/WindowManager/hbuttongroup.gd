extends Control
class_name HToggleButtonGroup

@export var ButtonGroupName: String = "buttongroup"
@onready var h_box_container: HBoxContainer = $HBoxContainer
var myButtons
var value:int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	myButtons = h_box_container.get_children()
	myButtons[0].button_pressed = true
	value = 0

func SetValue(val: int) -> void:
	value = clamp(val,0,myButtons.size())
	myButtons[value].button_pressed = true

func GetValue() -> int:
	for x in range(myButtons.size()):
		if myButtons[x].button_pressed == true:
			value = x
	return value

func UserSelection():
	var v = GetValue()
	## emit a signal that needs to badded to SignalBus or this won't work.
	SignalBus.HToggleButtonGroup.emit(v, ButtonGroupName)	
