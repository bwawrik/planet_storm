extends Node2D
class_name Tile

@export var tileImageVariants: Array[Texture]
@export var tileSprite: Sprite2D

var variant: int = 0

func _ready() -> void:
	variant = randi_range(0,tileImageVariants.size()-1)
	tileSprite.texture = tileImageVariants[variant]
	
