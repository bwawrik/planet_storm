# SCRIPTS/data_holders/unit_memory.gd
class_name UnitMemory extends RefCounted

enum Intent { IDLE, COLLECT, BUILD, FIGHT, WANDER, DELIVER, MINE }

var intent: Intent = Intent.IDLE
var target_position: Vector2i
var player_set_target = null
var path: PackedVector2Array
var path_index: int = 0
var order: Order = Order.new()

func set_goal(i: Intent, pos: Vector2, _node: Node2D = null) -> void:
	intent = i; 
	target_position = pos; 
	path = PackedVector2Array(); path_index = 0

func clear() -> void:
	intent = Intent.IDLE; 
	path = PackedVector2Array(); path_index = 0

func has_goal() -> bool:
	return intent != Intent.IDLE


## this helps to remember a player order e.g. a rock that is mined 
func SetPlayerTarget(p: Vector2i) -> void:
	player_set_target =p
func GetPlayerTarget() -> Vector2i:
	return player_set_target
func ErasePlayerTarget() -> void:
	player_set_target = null
	
