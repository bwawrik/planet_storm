class_name InventorySlot extends Resource

@export var item: InventoryItem
@export var amount: int

@export var max_amount: int

func _init(maximum_size: int = -1) -> void:
	
	if maximum_size == -1: 
		max_amount = 64000
	else: 
		max_amount = maximum_size
	
	
