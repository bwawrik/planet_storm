extends RefCounted
class_name StructureEconomy

var stats: StructureFlowStats
var modifiers: Array[StructureFlowModifier] = []

func _init(structure_stats: StructureFlowStats) -> void:
	stats = structure_stats

func add_modifier(modifier: StructureFlowModifier) -> void:
	modifiers.append(modifier)

func remove_modifier(vtex: int) -> void:
	modifiers = modifiers.filter(func(m): return m.vtex != vtex)

func has_modifier(vtex:int) -> bool:
	for mo in modifiers:
		if mo.vtex == vtex:
			return true
	return false

## replaces any existing modifier with the same source vertex instead of stacking duplicates;
## use this for modifiers re-derived from external state (e.g. adjacent tiles/structures)
func set_modifier(modifier: StructureFlowModifier) -> void:
	remove_modifier(modifier.vtex)
	modifiers.append(modifier)

## additive modifiers apply first, then multiplicative ones stack on top
func _effective_rate(flow: ResourceFlow, target: StructureFlowModifier.Target) -> float:
	var add_total: float = 0.0
	var mult_total: float = 1.0
	for modifier in modifiers:
		if modifier.target != target:
			continue
		if modifier.item != null and modifier.item != flow.item:
			continue
		if modifier.mode == StructureFlowModifier.Mode.ADD:
			add_total += modifier.value
		else:
			mult_total *= modifier.value
	return (flow.rate + add_total) * mult_total

## server-only: consumes required inputs first; if any is short, production halts entirely this tick
## caller (hab.gd) is responsible for gating this to the server, since RefCounted has no `multiplayer` access
func tick(player_slot: int, delta_seconds: float) -> Array:
	## if player not initialized
	if player_slot < 0: return []
	## if inventory not initialized (first tick)	
	var inventory: DynamicInventory = SharedData.map.GetPlayerInventory(player_slot)
	if inventory == null: return []
	
	var accounting = []

	for flow in stats.consumption:
		var amount: int = int(_effective_rate(flow, StructureFlowModifier.Target.CONSUMPTION) * delta_seconds)
		if amount <= 0:
			continue
		## return if required item not in inventory
		if not inventory.hasItem(flow.item, amount):
			return []
		inventory.RemoveItem(flow.item, amount)
		accounting.append ({"item": flow.item,"amount": -amount})

	for flow in stats.production:
		var amount: int = int(_effective_rate(flow, StructureFlowModifier.Target.PRODUCTION) * delta_seconds)
		if amount > 0:
			inventory.AddItem(flow.item, amount)
			accounting.append ({"item": flow.item,"amount": amount})
			print ('producing, ', flow.item)
	return accounting
