extends Control

@export var planet_visual: Array[Sprite2D]

var seleted: bool = false
var selectCouter: Counter


func _ready() -> void:
	selectCouter = Counter.new(0,4,1,0,true)
	SignalBus.connect("UpdatePlanets", _updatePlanets)
	for visual in planet_visual:
		if visual and visual.material is ShaderMaterial:
			visual.material = visual.material.duplicate()
	

func _updatePlanets(planetData: Array[PLANET]):
	## reset the counter
	selectCouter.max_value = planet_visual.size()
	if selectCouter.GetPosition() > planet_visual.size(): selectCouter.current_value = 0
	for s in range(5):
		planet_visual[s].selectionBox.visible = false
		if s==selectCouter.current_value:
			planet_visual[s].selectionBox.visible = true
	 
	for i in range(planet_visual.size()):
		var visual := planet_visual[i]
		if visual == null:
			push_warning("Planet viewer has an unassigned visual at index %d." % i)
			continue

		visual.visible = i < planetData.size()
		if i >= planetData.size():
			continue

		var planet := planetData[i]
		if planet == null:
			push_warning("Planet data is null at index %d." % i)
			visual.visible = false
			continue

		if not visual.material is ShaderMaterial:
			push_warning("Planet viewer visual at index %d has no ShaderMaterial." % i)
			continue

		planet.stats.apply_to(visual.material as ShaderMaterial)
