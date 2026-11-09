## Base class for all states
class_name StateFarmerMoveTo
extends State

const MOVE_SPEED := 100.0
const ARRIVAL_DISTANCE := 2.0



func enter(_previous_state_path: StringName, _data := {}) -> void:
	super.enter(_previous_state_path, _data)
	$"../../footsteps".playing = true
	actor.thoughts.text = "-->"

func exit() -> void:
	$"../../footsteps".playing = false

func update(delta: float) -> void:
	var map := SharedData.MAP as MapManager
	if map == null or actor.memory.path.is_empty():
		finished.emit("Idle", {})
		return

	var movement_parent := actor.get_parent() as Node2D
	while actor.memory.path_index < actor.memory.path.size():
		var waypoint = actor.memory.path[actor.memory.path_index]
		var waypoint_tile := Vector2i(roundi(waypoint.x), roundi(waypoint.y))
		var waypoint_global := map.terrainlayer.to_global(map.terrainlayer.map_to_local(waypoint_tile))
		var waypoint_local := movement_parent.to_local(waypoint_global)
		var offset := waypoint_local - actor.position
		var distance := offset.length()
		if distance <= ARRIVAL_DISTANCE:
			actor.position = waypoint_local
			actor.memory.path_index += 1
			continue

		_play_movement_animation(offset / distance)
		actor.position += offset / distance * minf(MOVE_SPEED * delta, distance)
		return

	match actor.memory.intent:
		UnitMemory.Intent.CHOP_WOOD:
			finished.emit("ChopTree", {})
		_:
			finished.emit("Idle", {})


func _play_movement_animation(direction: Vector2) -> void:
	var animation_name := "run_down"
	var flip_h := false

	if direction.y < -0.35:
		if absf(direction.x) > 0.35:
			animation_name = "run_upright"
			flip_h = direction.x < 0.0
		else:
			animation_name = "run_up"
	elif direction.y > 0.35:
		if absf(direction.x) > 0.35:
			animation_name = "run_downright"
			flip_h = direction.x < 0.0
	else:
		animation_name = "run_right"
		flip_h = direction.x < 0.0

	actor.mySprite.flip_h = flip_h
	if actor.mySprite.animation != animation_name:
		actor.mySprite.play(animation_name)
