
# res://scripts/planet.gd
class_name PLANET
extends Sprite2D

var stats := PlanetStats.new()

func _ready() -> void:
	# 1) Ensure this node has its own ShaderMaterial instance (not shared).
	if material is ShaderMaterial:
		material = material.duplicate()
		material.resource_local_to_scene = true
	else:
		push_warning("Sprite2D has no ShaderMaterial — cannot apply planet stats.")
		return

	# 2) Give this planet a unique seed and randomize.
	#    Using high-resolution time avoids collisions when multiple nodes ready the same frame.
	stats.planet_seed = int(Time.get_ticks_usec() % 2000) + int(Time.get_ticks_msec() % 2000)

	# Call with positional arguments (no named assignment in GDScript calls).
	# Second arg = use_seed
	stats.randomize_planet(PlanetStats.PlanetType.RANDOM, true)
	
	# 3) Push all shader parameters into this material.
	ApplyToMaterial()

func ApplyToMaterial():
	stats.apply_to(material as ShaderMaterial)


# Optional: expose a re-roll method you can call at runtime or from the editor
func reroll_planet() -> void:
	stats.planet_seed = int(Time.get_ticks_usec() % 2000) + int(Time.get_ticks_msec() % 2000)
	stats.randomize_planet(PlanetStats.PlanetType.RANDOM, true)
	if material is ShaderMaterial:
		stats.apply_to(material as ShaderMaterial)
