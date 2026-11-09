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

signal StartGame()

signal UpdatePlanets(planetData: Array[PLANET])
signal StarSelected(planetData: Array[PLANET])

# general navigation
signal UnselectAll()
signal selectArea(area: Rect2) # global_position rect
signal SelectionBoxStarted()

# tile signals
signal Timber(pos:Vector2i)

#menu signals
signal ItemSelected(itm: InventoryItem)
signal CircleMenuVisible(visible: bool, pos: Vector2) # Viewport coordinates.
signal TextSignal(str: String)
