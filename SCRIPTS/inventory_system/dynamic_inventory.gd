extends Inventory
class_name DynamicInventory

## RPCs can't reconstruct Resource objects, so send/receive inventories as plain data instead
func to_dict() -> Dictionary:
	var slot_data: Array = []
	for slot in slots:
		slot_data.append({
			"item_path": slot.item.resource_path if slot.item else "",
			"amount": slot.amount,
			"max_amount": slot.max_amount
		})
	return {"slots": slot_data}

func from_dict(data: Dictionary) -> void:
	slots.clear()
	for slot_data: Dictionary in data.get("slots", []):
		var new_slot := InventorySlot.new()
		var item_path: String = slot_data.get("item_path", "")
		if item_path != "":
			new_slot.item = load(item_path)
		new_slot.amount = slot_data.get("amount", 0)
		new_slot.max_amount = slot_data.get("max_amount", 64000)
		slots.append(new_slot)

func AddItem(new_item: InventoryItem, n: int):
	#if CanAdd(new_item, n) == false: return false
	for slot in slots:
		##add to slot that already contains item
		if slot.item == new_item:
			slot.amount += n
			SignalBus.update_inventories.emit()
			return (true)
		##put into existing slot that's empty
	for slot in slots:
		if slot.amount == 0:
			slot.item = new_item
			slot.amount = n
			SignalBus.update_inventories.emit()
			return (true)
	##for dynamic inventories uncomment the lines below
	##if you can't find one, create one
	var new_slot = InventorySlot.new()
	new_slot.item = new_item
	new_slot.amount = n
	slots.append(new_slot)

func RemoveItem(item_to_remove: InventoryItem, n:int):
	for slot in slots:
		if slot.item == item_to_remove:
			slot.amount -= n
			##for dynamic inventories uncomment the lines below
			if slot.amount == 0:
				slots.erase(slot)
			return


func _iter_init(arg):
	if slots.is_empty():
		return false
	arg[0] = 0 # Initialize index 0 of the iterator state array
	return true

func _iter_next(arg):
	arg[0] += 1 # Increment index 0 of the iterator state array
	if arg[0] < slots.size():
		return true
	return false

func _iter_get(arg):
	return slots[arg[0]] # Access your slots array using the state value

func getSlots():
	return slots
