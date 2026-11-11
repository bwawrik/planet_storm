# SCRIPTS/data_holders/unit_memory.gd
class_name UnitMemory extends RefCounted

enum Intent { IDLE, CHOP_WOOD, BUILD, FIGHT, WANDER, DELIVER }

var intent: Intent = Intent.IDLE
var target_position: Vector2i
var path: PackedVector2Array
var path_index: int = 0

func set_goal(i: Intent, pos: Vector2, node: Node2D = null) -> void:
	intent = i; 
	target_position = pos; 
	path = PackedVector2Array(); path_index = 0

func clear() -> void:
	intent = Intent.IDLE; 
	path = PackedVector2Array(); path_index = 0

func has_goal() -> bool:
	return intent != Intent.IDLE
