@tool
extends Control

@export var unselctedStyleBox: StyleBoxFlat
@export var selectedStyleBox: StyleBoxFlat
@export var item: InventoryItem

@onready var texture_rect: TextureRect = $TextureRect

signal selected(item: InventoryItem)


func _ready() -> void:
	if item:
		texture_rect.texture = item.texture
	else:
		push_error("Circle menu icon has no item assigned: %s" % get_path())
	focus_entered.connect(_focus)
	focus_exited.connect(_unfocus)
	_unfocus()

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and not event.is_echo():
		_select()
		accept_event()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		grab_focus()
		_select()
		accept_event()

func _select() -> void:
	if item:
		selected.emit(item)

func _focus():
	add_theme_stylebox_override("panel", selectedStyleBox)
	SharedData.PlaySound(SharedData.soundEffects[5])
	
func _unfocus():
	add_theme_stylebox_override("panel", unselctedStyleBox)
