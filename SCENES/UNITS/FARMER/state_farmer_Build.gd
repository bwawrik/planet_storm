## Base class for all states
class_name StateFarmer_Build
extends State

var work_tile
var hammer_was_playing := false

func enter(_previous_state_path: StringName, _data := {}) -> void:
	var current_tile = SharedData.MAP.terrainlayer.local_to_map(SharedData.MAP.terrainlayer.to_local(actor.global_position))
	var totem = SharedData.MAP.FindTotemAt(current_tile)
	if totem == null or totem.recipe == null:
		finished.emit("Idle", {})
		return
	SharedData.MAP.PlaceStructure(current_tile, totem.recipe)
	work_tile = _FindNearestStructure()
	totem.queue_free()
	actor.mySprite.play("hammering")
	set_process(true)

func exit() -> void:
	set_process(false)
	work_tile = null

func _ready() -> void:
	set_process(false)

# Nearest structure to the farmer; avoids depending on the cell key a structure was registered under.
func _FindNearestStructure():
	var best = null
	var best_dist := INF
	for s in SharedData.MAP.structures.values():
		var d = s.global_position.distance_squared_to(actor.global_position)
		if d < best_dist:
			best = s
			best_dist = d
	return best
	
func _process(_delta: float) -> void:
	var playing: bool = actor.mySprite.is_playing()
	if hammer_was_playing and not playing:
		work_tile = _FindNearestStructure()
		work_tile.increment_construction_stage()
		SharedData.PlaySound(SharedData.soundEffects[24])
		if work_tile.is_complete:
			#actor.current_order = actor.POSSIBLE_ORDERS.GATHER
			finished.emit("Idle", {})
			return
		actor.mySprite.play("hammering")
		playing = true
	hammer_was_playing = playing
