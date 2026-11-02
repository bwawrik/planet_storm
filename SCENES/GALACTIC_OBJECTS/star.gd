extends Sprite2D
class_name STAR

@export var numPlanets: int
@export var planets: Array[PLANET]


func _init() -> void:
	pass
	
func configure(numPlanets: int):
	if numPlanets > 5: numPlanets =5
	if numPlanets <1: numPlanets =1
	var p := PLANET.new()
	
func _initRandom():
	numPlanets = randi_range(2, 5)
	for n in range(numPlanets):
		var p := PLANET.new()
		p.reroll_planet()
		planets.append(p)

func _initUniform(numPlanets: int, type:PlanetStats.PlanetType):
	if numPlanets > 5: numPlanets =5
	if numPlanets <1: numPlanets =1
	for n in range(numPlanets):
		var p := PLANET.new()
		p.reroll_planet(type)
		planets.append(p)
	



func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		SignalBus.emit_signal("StarSelected", planets)
