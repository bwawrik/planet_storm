class_name Order
extends RefCounted

enum ResourceType {NONE, TREES, ROCKS, MINE}

var resource_type: ResourceType 
var anchor_position: Vector2i
var search_radius: int = 10
var preferred_target: ResourceType

func _init() -> void:
	resource_type = ResourceType.NONE
	
