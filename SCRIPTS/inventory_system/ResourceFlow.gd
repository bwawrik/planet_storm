extends Resource
class_name ResourceFlow

## one line item of a structure's production or consumption list
@export var item: InventoryItem
@export var rate: int = 1 ## units per second, before modifiers
