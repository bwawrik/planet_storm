## Base class for all states
class_name StateFarmerIdle
extends State

const PONDER_DURATION := 0.4
const TREE_SEARCH_DISTANCE := 6
const SPOT_SEARCH_DISTANCE := 6
const WANDER_DISTANCE := 4

var ponderTimer: float = PONDER_DURATION


func enter(_previous_state_path: StringName, _data := {}) -> void:
	super.enter(_previous_state_path, _data)
	ponderTimer = PONDER_DURATION
	actor.thoughts.text = "?"
	actor.mySprite.play("idle")

func update(delta: float) -> void:
	ponderTimer -= delta
	if ponderTimer > 0.0: return
	ponderTimer = PONDER_DURATION

	var map := SharedData.MAP as MapManager
	if map == null: return

	var current_tile := map.terrainlayer.local_to_map(map.terrainlayer.to_local(actor.global_position))
	if _has_cargo():
		_decide_when_carrying(map, current_tile)
	else:
		_decide_when_empty_handed(map, current_tile)


## Decision tree: carrying cargo.
## 1. if current_order == POSSIBLE_ORDERS.GATHER, deliver to portal
## 2. If at portal add cargo to inventory and go back to orders
## 3. Otherwise, wander.
func _decide_when_carrying(map: MapManager, from: Vector2i) -> void:
	var to = Vector2i.ZERO	
	if from == to:
		SharedData.gameManager.inv.AddItem(actor.cargo.item, actor.cargo.amount)
		SharedData.PlaySound(SharedData.soundEffects[23],null,0.5)
		actor.cargo.item = null
		actor.cargo.amount = 0
		return

	if actor.current_order == actor.POSSIBLE_ORDERS.GATHER:
		
		_start_move(map, from, to, UnitMemory.Intent.DELIVER) 
		return
	else:		
		var spots = map.FindClearSpotsWithin(from, SPOT_SEARCH_DISTANCE)
		if _go_to_nearest(map, from, spots, UnitMemory.Intent.DELIVER): return
		_wander(map, from)


## Decision tree: empty handed.
## 1. if order current_order == POSSIBLE_ORDERS.CHOP_WOOD Walk to the nearest reachable tree and chop it.
## 2. Otherwise, wander.
func _decide_when_empty_handed(map: MapManager, from: Vector2i) -> void:
	if actor.memory.order.resource_type != Order.ResourceType.NONE:
		_continue_resource_order(map, from)
		return

	match actor.current_order:
		actor.POSSIBLE_ORDERS.GATHER:
			var trees := map.FindTreesWithin(from, TREE_SEARCH_DISTANCE)
			var rocks := map.FindRocksWithin(from, TREE_SEARCH_DISTANCE)
			var tree_path := _nearest_path(map, from, trees)
			var rock_path := _nearest_path(map, from, rocks)
			if not rock_path.is_empty() and (tree_path.is_empty() or rock_path.size() < tree_path.size()):
				_begin_move(rock_path, UnitMemory.Intent.MINE)
				return
			if not tree_path.is_empty():
				_begin_move(tree_path, UnitMemory.Intent.COLLECT)
				return
			_wander(map, from)
		actor.POSSIBLE_ORDERS.BUILD:
			var totem_pos = map.FindNearestTotem(from)
			if totem_pos == null:
				# Keep the selected build order; the next idle update checks again.
				return
			_start_move(map, from, totem_pos, UnitMemory.Intent.BUILD)
			return
		_:
			_wander(map, from)


func _continue_resource_order(map: MapManager, from: Vector2i) -> void:
	var order: Order = actor.memory.order
	var resource: Order.ResourceType = order.preferred_target
	if resource == Order.ResourceType.NONE:
		resource = Order.ResourceType.ROCKS if order.resource_type == Order.ResourceType.MINE else order.resource_type

	var targets: Array[Vector2i] = []
	match resource:
		Order.ResourceType.ROCKS:
			targets = map.FindRocksWithin(order.anchor_position, order.search_radius)
		Order.ResourceType.TREES:
			targets = map.FindTreesWithin(order.anchor_position, order.search_radius)
		_:
			return

	if targets.has(order.anchor_position):
		if _start_move(map, from, order.anchor_position, _intent_for_resource(resource)):
			return
	var best_path := _nearest_path(map, from, targets)
	if not best_path.is_empty():
		_begin_move(best_path, _intent_for_resource(resource))


func _intent_for_resource(resource: Order.ResourceType) -> UnitMemory.Intent:
	if resource == Order.ResourceType.ROCKS:
		return UnitMemory.Intent.MINE
	return UnitMemory.Intent.COLLECT


func _wander(map: MapManager, from: Vector2i) -> void:
	var spots := map.FindWalkableWithin(from, WANDER_DISTANCE)
	spots.shuffle()
	for spot in spots:
		if _start_move(map, from, spot, UnitMemory.Intent.WANDER): return


## Picks the closest (by path length) reachable target and starts moving. Returns false if none.
func _go_to_nearest(map: MapManager, from: Vector2i, targets: Array[Vector2i], intent: UnitMemory.Intent) -> bool:
	var best_path := _nearest_path(map, from, targets)
	if best_path.is_empty(): return false
	_begin_move(best_path, intent)
	return true


func _nearest_path(map: MapManager, from: Vector2i, targets: Array[Vector2i]) -> PackedVector2Array:
	var best_path := PackedVector2Array()
	for target in targets:
		var path := map.FindPath(from, target)
		if path.is_empty(): continue
		if best_path.is_empty() or path.size() < best_path.size():
			best_path = path
		elif path.size() == best_path.size():
			if randi_range(0,1) == 1:
				best_path = path
	return best_path


func _start_move(map: MapManager, from: Vector2i, target: Vector2i, intent: UnitMemory.Intent) -> bool:
	var path := map.FindPath(from, target)
	if path.is_empty(): return false
	_begin_move(path, intent)
	return true


func _begin_move(path: PackedVector2Array, intent: UnitMemory.Intent) -> void:
	actor.memory.intent = intent
	actor.memory.target_position = Vector2i(path[path.size() - 1])
	actor.memory.path = path
	actor.memory.path_index = 0
	finished.emit("MoveTo", {})


func _has_cargo() -> bool:
	return actor.cargo.item != null and actor.cargo.amount > 0
