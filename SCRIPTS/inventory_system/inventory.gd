extends Resource

class_name Inventory

@export var slots : Array[InventorySlot] 
var slot_size: int = -1 ## -1 means default value of 64k

#signal signal_update_inventory

func _init(number_of_slots: int = 0, maxSlotSize: int = -1) -> void:
	slot_size = maxSlotSize
	if number_of_slots > 0: 
		addSlots(number_of_slots)

func size():
	return slots.size()

func addSlots(_n:int=1):
	for x in range(_n):
		var newSlot = InventorySlot.new(slot_size)
		slots.append(newSlot)
	SignalBus.update_inventories.emit()
	#signal_update_inventory.emit()

func CanAddUnique (new_item: InventoryItem) -> bool:
	for slot in slots:
		if slot.item == new_item: 
			if slot.amount > 0:
				return false
	return true

func CanAdd(new_item: InventoryItem, n: int) -> bool:
	## for static inventories
	for slot in slots:
		if slot.item == new_item: 
			if slot.amount + n < slot.max_amount:
				return (true)
		if slot.amount == 0: 
			return (true)
	return false
	
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
	#var new_slot = InventorySlot.new()
	#new_slot.item = new_item
	#new_slot.amount = n
	#slots.append(new_slot)
	#signal_update_inventory.emit()
	#PukeConent()
	##if you didn't find a usable slot return false
	return (false)

func RemoveItem(item_to_remove: InventoryItem, n:int):
	for slot in slots:
		if slot.item == item_to_remove:
			slot.amount -= n
			##for dynamic inventories uncomment the lines below
			#if slot.amount == 0:
			#	slots.erase(slot)
			SignalBus.update_inventories.emit()
			#signal_update_inventory.emit()
			#PukeConent()		
			return

func hasItem(itm, n) -> bool:
	for slot in slots:
		if slot.item == itm:
			if slot.amount >= n:
				return true
	return false

func hasEmptySlot() -> bool:
	for slot in slots:
		if slot.amount ==0:
			return true
	return false

func getSlots():
	return slots


func PukeConent():
	print ("=================")
	for slot in slots:
		if slot.item:
			print (slot.item.name)
			print (slot.amount)
			print ("-------------")
	print ("=================")
