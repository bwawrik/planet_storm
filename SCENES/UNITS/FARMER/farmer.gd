extends CharacterBody2D

var memory: UnitMemory

@onready var qmarks = $questionmarks

func _ready() -> void:
	## initialize unit memmory
	memory = UnitMemory.new()
	
