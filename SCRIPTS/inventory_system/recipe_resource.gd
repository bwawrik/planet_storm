extends Resource

class_name ItemRecipe

@export var name: StringName
@export var unlocked: bool = true
@export var item: InventoryItem
@export var ingredients: Array[InventorySlot]


## check if ingredients are in inventory
func CanMake(inv, inv_alt: Inventory = null, _checkAddable: bool = true) -> bool:
	for i in ingredients:
		if inv_alt == null:
			if inv.hasItem(i.item, i.amount) == false: 
				return false
		else:
			if inv.hasItem(i.item, i.amount) == false and inv_alt.hasItem(i.item, i.amount) == false: 
				return false
	if _checkAddable:
		if inv.CanAdd(item, 1) == false: 
			return false
	return true
	
func Make(inv, inv_alt: Inventory = null) -> InventoryItem:
	if CanMake(inv, inv_alt) == false: 
		return null
	else:
		for i in ingredients:
			if inv.hasItem(i.item, i.amount) == true:
				inv.RemoveItem(i.item, i.amount)
			elif inv_alt.hasItem(i.item, i.amount) == true:
				inv_alt.RemoveItem(i.item, i.amount)
			else: 
				return null
		var canAdd = inv.AddItem(item, 1)
		if canAdd == true:
			return null
		else:
			return item
	
