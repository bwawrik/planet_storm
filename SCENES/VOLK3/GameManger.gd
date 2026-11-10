extends Node2D
class_name GameManger

@export var inv: DynamicInventory

func _ready() -> void:
	SharedData.gameManager = self
	inv = DynamicInventory.new()
	




	
