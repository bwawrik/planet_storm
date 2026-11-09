extends Node2D

var memory: UnitMemory
var cargo: InventorySlot

@export var thoughts: Label
@export var mySprite: AnimatedSprite2D
@export var myCollsionArea: Area2D
@export var cargoSprite: Sprite2D
@export var selectorSprite: Sprite2D

var selected: bool = false

var totems = {}
var enemies = {}

func _ready() -> void:
	## initialize unit memmory
	memory = UnitMemory.new()
	cargo = InventorySlot.new()
	SignalBus.UnselectAll.connect(_unselect)
	SignalBus.selectArea.connect(_on_select_area)
	
func _process(delta: float) -> void:
	if cargo.amount ==0 or cargo.item == null:
		cargoSprite.visible = false
	else:
		cargoSprite.visible = true
		cargoSprite.texture = cargo.item.texture

	selectorSprite.visible = selected

func _on_collision_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		selected = true


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed and selected:
		selected = false
		var map := SharedData.MAP as MapManager
		if map == null:
			return
		var target := map.terrainlayer.local_to_map(map.terrainlayer.to_local(get_global_mouse_position()))
		var from := map.terrainlayer.local_to_map(map.terrainlayer.to_local(global_position))
		var path := map.FindPath(from, target)
		if path.is_empty():
			return

		memory.intent = UnitMemory.Intent.WANDER
		memory.target_position = target
		memory.path = path
		memory.path_index = 0
		var state_machine := $actor as StateMachine
		state_machine.state.finished.emit("MoveTo", {})

func _on_select_area(area: Rect2) -> void:
	if area.has_point(global_position):
		selected = true

func _unselect():
	selected = false
