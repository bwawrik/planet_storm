## Base class for all states
class_name StateFarmerIdle
extends State

const PONDER_DURATION := 2.0
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
## 1. Walk to a spot with no trees on or next to it.
## 2. Otherwise, wander.
func _decide_when_carrying(map: MapManager, from: Vector2i) -> void:
	var spots = map.FindClearSpotsWithin(from, SPOT_SEARCH_DISTANCE)
	if _go_to_nearest(map, from, spots, UnitMemory.Intent.DELIVER): return
	_wander(map, from)


## Decision tree: empty handed.
## 1. Walk to the nearest reachable tree and chop it.
## 2. Otherwise, wander.
func _decide_when_empty_handed(map: MapManager, from: Vector2i) -> void:
	var trees := map.FindTreesWithin(from, TREE_SEARCH_DISTANCE)
	if _go_to_nearest(map, from, trees, UnitMemory.Intent.CHOP_WOOD): return
	_wander(map, from)


func _wander(map: MapManager, from: Vector2i) -> void:
	var spots := map.FindWalkableWithin(from, WANDER_DISTANCE)
	spots.shuffle()
	for spot in spots:
		if _start_move(map, from, spot, UnitMemory.Intent.WANDER): return


## Picks the closest (by path length) reachable target and starts moving. Returns false if none.
func _go_to_nearest(map: MapManager, from: Vector2i, targets: Array[Vector2i], intent: UnitMemory.Intent) -> bool:
	var best_path := PackedVector2Array()
	for target in targets:
		var path := map.FindPath(from, target)
		if path.is_empty(): continue
		if best_path.is_empty() or path.size() < best_path.size():
			best_path = path
	if best_path.is_empty(): return false
	_begin_move(best_path, intent)
	return true


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
