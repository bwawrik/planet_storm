class_name Structure
extends Node2D

#@onready var house: AnimatedSprite2D = $House

@export var mySprite:AnimatedSprite2D

@export var n_stages:int = 5

var construction_stage:int = 0
var is_complete: bool = false
var pos: Vector2i

func _ready() -> void:
	n_stages = mySprite.sprite_frames.get_frame_count("default")
	mySprite.frame = construction_stage
	var layer = SharedData.MAP.buildingLayer
	pos = layer.local_to_map(layer.to_local(global_position))
	SharedData.MAP.RegisterStructure(self)

func _exit_tree() -> void:
	SharedData.MAP.UnregisterStructure(self)

func increment_construction_stage() -> void:
	if is_complete:
		return
	construction_stage += 1
	mySprite.frame = construction_stage
	if construction_stage >= n_stages:
		construction_stage = n_stages
		is_complete = true
