##add this to scene to globals
extends Node

##examples
#signal player_damaged(damage: float)
#signal item_collected(item_name: String)
#signal punch_started()

## to connect
#SignalBus.connect("inventory_updated", _update_inventory)
#SignalBus.narrative.connect(function_name)
#SignalBus.emit_signal("narrative", "thank you for choosing")
signal connect_windows()

##examples
#signal player_damaged(damage: float)
#signal item_collected(item_name: String)
#signal punch_started()


signal UpdatePlanets(planetData: Array[PLANET])
signal StarSelected(planetData: Array[PLANET])
