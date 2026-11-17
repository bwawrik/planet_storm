extends Control

@onready var n_gold: RichTextLabel = $MarginContainer/VBoxContainer/gold/n_gold
@onready var n_wood: RichTextLabel = $MarginContainer/VBoxContainer/wood/n_wood
@onready var n_water: RichTextLabel = $MarginContainer/VBoxContainer/water/n_water
@onready var n_food: RichTextLabel = $MarginContainer/VBoxContainer/food/n_food

var last = {
	"GOLD":"0",
	"WOOD":"0",
	"WATER":"0",
	"FOOD":"0",
}

func _process(_deltaTime: float) -> void:
	if SharedData.gameManager == null:
		return

	var counts: Dictionary = {
		"GOLD": 0,
		"WOOD": 0,
		"WATER": 0,
		"FOOD": 0,
	}

	for slot in SharedData.gameManager.inv.slots:
		if slot.item == null:
			continue
		if counts.has(slot.item.name):
			counts[slot.item.name] = slot.amount

	if counts["GOLD"] != int(last.GOLD):
		last.GOLD = str(counts["GOLD"])
		n_gold.text = last.GOLD
		_blip(n_gold)

	if counts["WOOD"] != int(last.WOOD):
		last.WOOD = str(counts["WOOD"])
		n_wood.text = last.WOOD
		_blip(n_wood)

	if counts["WATER"] != int(last.WATER):
		last.WATER = str(counts["WATER"])
		n_water.text = last.WATER
		_blip(n_water)

	if counts["FOOD"] != int(last.FOOD):
		last.FOOD = str(counts["FOOD"])
		n_food.text = last.FOOD
		_blip(n_food)


var blipLength : float = 0.1
var sizeBlip : float = 1.4
# over time blipLength smoothly increase size to sizeBlip; then reset to size 1
func _blip(label: RichTextLabel) -> void:
	# Create a tween for the smooth scaling animation
	var tween = create_tween()
	
	# Smoothly increase the scale to sizeBlip over half the duration
	tween.tween_property(label, "scale", Vector2(sizeBlip, sizeBlip), blipLength / 2.0)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		
	# Smoothly scale back down to 1.0 over the remaining half duration
	tween.tween_property(label, "scale", Vector2.ONE, blipLength / 2.0)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	# Pause execution of this function until the entire tween finishes
	await tween.finished
