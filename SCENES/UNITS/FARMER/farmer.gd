extends Node2D

var memory: UnitMemory
var cargo: InventorySlot

enum POSSIBLE_ORDERS {IDLE, GATHER, BUILD, DELIVER, FIGHT}
var current_order = POSSIBLE_ORDERS.GATHER

@export var thoughts: Label
@export var mySprite: AnimatedSprite2D
@export var myCollsionArea: Area2D
@export var cargoSprite: Sprite2D
@export var selectorSprite: Sprite2D
@export var eye_sounds: Array[AudioStream]


var selected: bool = false

func _ready() -> void:
	## initialize unit memmory
	memory = UnitMemory.new()
	cargo = InventorySlot.new()
	SignalBus.UnselectAll.connect(_unselect)
	SignalBus.selectArea.connect(_on_select_area)
	SignalBus.RightClickOnMap.connect(RightClickEvent)
	SignalBus.HToggleButtonGroup.connect(NewOrders)
	
func _process(_delta: float) -> void:
	if cargo.amount ==0 or cargo.item == null:
		cargoSprite.visible = false
	else:
		cargoSprite.visible = true
		cargoSprite.texture = cargo.item.texture
	selectorSprite.visible = selected

func _on_collision_area_input_event(_viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		selected = true
		SignalBus.UnitSelected.emit(current_order)
		print ("clicked:", self)



func RightClickEvent(event: InputEvent) -> void:
	if selected:
		#selected = false
		var map := SharedData.MAP as MapManager
		if map == null:
			return
		var target := map.terrainlayer.local_to_map(map.terrainlayer.to_local(get_global_mouse_position()))
		var from := map.terrainlayer.local_to_map(map.terrainlayer.to_local(global_position))

		_set_order_from_tile(map, target)
		memory.order.anchor_position = target
		var state_machine := $actor as StateMachine

		if cargo.item != null and cargo.amount > 0 and memory.order.resource_type != Order.ResourceType.NONE:
			state_machine.state.finished.emit("Idle", {})
			eye_sound()
			return

		var path := map.FindPath(from, target)
		if not path.is_empty():
			var intent := _order_intent_for_target(map, target)
			memory.intent = intent if intent != UnitMemory.Intent.IDLE else UnitMemory.Intent.WANDER
			memory.target_position = target
			memory.path = path
			memory.path_index = 0
		elif memory.order.resource_type != Order.ResourceType.NONE:
			# Keep the order even when its anchor cannot currently be reached.
			return
		else:
			return

		state_machine.state.finished.emit("MoveTo", {})
		eye_sound()


func _set_order_from_tile(map: MapManager, target: Vector2i) -> void:
	if map.FindRocksWithin(target, 0).size() > 0:
		memory.order.resource_type = Order.ResourceType.MINE
		memory.order.preferred_target = Order.ResourceType.ROCKS
		current_order = POSSIBLE_ORDERS.GATHER
	elif map.FindTreesWithin(target, 0).size() > 0:
		memory.order.resource_type = Order.ResourceType.TREES
		memory.order.preferred_target = Order.ResourceType.TREES
		current_order = POSSIBLE_ORDERS.GATHER


func _order_intent_for_target(map: MapManager, target: Vector2i) -> UnitMemory.Intent:
	if map.FindRocksWithin(target, 0).size() > 0:
		return UnitMemory.Intent.MINE
	if map.FindTreesWithin(target, 0).size() > 0:
		return UnitMemory.Intent.COLLECT
	return UnitMemory.Intent.IDLE
		
func _on_select_area(area: Rect2) -> void:
	if area.has_point(global_position):
		selected = true
		SignalBus.UnitSelected.emit(current_order)
		

func _unselect():
	selected = false

func NewOrders(v: int, ButtonGroupName: String) -> void:
	if ButtonGroupName != "UnitActivityPanel": return
	if selected == false: return
	current_order = v
	memory.order.resource_type = Order.ResourceType.NONE
	memory.order.preferred_target = Order.ResourceType.NONE
	eye_sound()

func eye_sound():
	$eye.stream = eye_sounds[randi_range(0,eye_sounds.size()-1)]
	$eye.play()
	
