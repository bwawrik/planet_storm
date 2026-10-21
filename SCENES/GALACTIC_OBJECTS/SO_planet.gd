
# res://resources/planet_stats.gd
extends Resource
class_name PlanetStats

enum PlanetType {
	TERRAN,
	GAS_GIANT,
	OCEAN_WORLD,
	ICE_PLUTOID,
	BARREN,
	GREENHOUSE,
	ICE_GIANT,
	RANDOM
}

func _init() -> void:
	randomize_planet()

@export var type: PlanetType = PlanetType.TERRAN

## ───── General (Planet) ──────────────────────────────────────────────────────
@export_group("Planet")
@export_range(0.0, 2000.0, 1.0) var planet_seed := 7.0
@export var randomize_params := false
@export var enforce_type_rules := true
@export_range(0.0, 1.0, 0.01) var temperature := 0.5
@export_range(0.0, 1.0, 0.01) var ocean_coverage := 0.55
@export_range(0.0, 1.0, 0.01) var atmosphere_density := 0.6
@export_range(0.0, 1.0, 0.01) var life_level := 0.6
@export_range(0.3, 1.0, 0.01) var planet_radius := 0.8
@export_range(0.0, 1.0, 0.01) var hue_variation := 0.12

## ───── Light ─────────────────────────────────────────────────────────────────
@export_group("Light")
@export_range(0.0, 1.0, 0.01) var sensor_level := 1.0
@export_range(0.0, 360.0, 0.1) var light_angle_deg := 35.0
@export_range(-0.9, 0.95, 0.01) var light_facing := 0.35
@export var sun_color: Color = Color(1.0, 0.96, 0.88, 1.0)
@export_range(0.0, 0.3, 0.005) var ambient_light := 0.025
@export_range(0.2, 2.5, 0.01) var exposure := 1.0

## ───── Motion ────────────────────────────────────────────────────────────────
@export_group("Motion")
@export_range(0.0, 8.0, 0.01) var time_scale := 1.0
@export_range(-1.0, 1.0, 0.001) var rotation_speed := 0.06
@export_range(-60.0, 60.0, 0.5) var axial_tilt_deg := 12.0
@export_range(0.0, 90.0, 0.5) var tilt_variation_deg := 30.0
@export_range(-0.5, 0.5, 0.001) var cloud_wind := 0.02
@export_range(-3.0, 3.0, 0.01) var hurricane_spin := 0.6
@export_range(0.0, 2.0, 0.01) var gas_flow_speed := 0.6

## ───── Terrain ───────────────────────────────────────────────────────────────
@export_group("Terrain")
@export_range(0.5, 8.0, 0.05) var terrain_scale := 2.2
@export_range(1, 8) var terrain_octaves: int = 5
@export_range(0.0, 1.0, 0.01) var mountain_amount := 0.6
@export_range(0.0, 3.0, 0.01) var relief := 1.0
@export_range(0.0, 1.0, 0.01) var crater_amount := 0.6
@export_range(0.0, 1.5, 0.01) var lat_gradient := 0.75
@export_range(0.0, 2.0, 0.01) var water_glint := 0.8

## ───── Gas Giant ─────────────────────────────────────────────────────────────
@export_group("Gas_Giant")
@export_range(2.0, 14.0, 0.1) var gas_band_count := 6.0
@export_range(0.0, 2.0, 0.01) var gas_turbulence := 1.0

## ───── Clouds & Storms ──────────────────────────────────────────────────────
@export_group("Clouds_And_Storms")
@export_range(0.0, 1.0, 0.01) var cloud_coverage := 0.55
@export_range(0.0, 1.0, 0.01) var cloud_opacity := 0.9
@export_range(0.5, 8.0, 0.05) var cloud_scale := 2.6
@export_range(1, 8) var cloud_octaves: int = 5
@export_range(0.0, 1.0, 0.01) var cloud_shadows := 0.5
@export_range(0.0, 1.0, 0.01) var storm_activity := 0.45
@export_range(0.0, 1.0, 0.01) var lightning_activity := 0.5

## ───── Atmosphere ───────────────────────────────────────────────────────────
@export_group("Atmosphere")
@export_range(0.0, 0.5, 0.005) var atmo_halo_size := 0.12
@export_range(0.0, 3.0, 0.01) var atmo_halo_strength := 1.0
@export_range(0.0, 3.0, 0.01) var atmo_rim_strength := 1.0
@export_range(0.5, 8.0, 0.05) var atmo_rim_power := 3.0

## ───── Civilization ─────────────────────────────────────────────────────────
@export_group("Civilization")
@export_range(0.0, 1.0, 0.01) var city_density := 0.5
@export_range(0.0, 1.0, 0.01) var tech_level := 0.5
@export_range(1.0, 10.0, 0.1) var city_scale := 3.5
@export_range(10.0, 120.0, 1.0) var city_detail := 48.0
@export_range(20.0, 240.0, 1.0) var city_grid_lines := 90.0
@export_range(0.0, 4.0, 0.01) var city_glow := 1.6
@export_range(0.0, 2.0, 0.01) var city_outline := 0.6
@export_range(0.0, 1.0, 0.01) var city_daytime_visibility := 0.35

## ───── Wildfire & Life ──────────────────────────────────────────────────────
@export_group("Wildfire_And_Life")
@export_range(0.0, 1.0, 0.01) var wildfire_activity := 0.25
@export_range(1.0, 12.0, 0.1) var fire_scale := 5.0
@export_range(20.0, 160.0, 1.0) var life_grid := 70.0
@export_range(0.05, 0.5, 0.01) var life_dot_size := 0.22
@export_range(0.0, 1.0, 0.01) var life_dot_opacity := 0.7
@export_range(0.0, 4.0, 0.01) var life_speed := 0.8
@export_range(0.0, 2.0, 0.01) var life_generation_rate := 0.25

## ───── Sensor & Pixelation ──────────────────────────────────────────────────
@export_group("Sensor_And_Pixelation")
@export var sensor_gating := true
@export_enum("Off", "Sensor driven", "Fixed") var pixelate_mode := 1
@export_range(6.0, 64.0, 1.0) var pixels_min := 12.0
@export_range(32.0, 512.0, 1.0) var pixels_max := 140.0
@export_range(0.3, 3.0, 0.05) var sensor_curve := 1.0
@export_range(8.0, 512.0, 1.0) var fixed_pixels := 64.0
@export var sensor_posterize := true
@export_range(0.0, 1.0, 0.01) var sensor_noise := 0.5
@export_range(0.0, 1.0, 0.01) var sensor_scanlines := 0.4
@export var unknown_color: Color = Color(0.35, 0.47, 0.6, 1.0)

## ───── Performance ──────────────────────────────────────────────────────────
@export_group("Performance")
@export var auto_lod := true
@export_range(4.0, 64.0, 1.0) var lod_min_pixels := 10.0
@export_range(64.0, 1024.0, 1.0) var lod_full_pixels := 180.0

## ───── Palettes ─────────────────────────────────────────────────────────────
@export_group("Palette_Rocky")
@export var ocean_shallow: Color = Color(0.12, 0.45, 0.62, 1.0)
@export var ocean_deep:    Color = Color(0.02, 0.10, 0.30, 1.0)
@export var land_low:      Color = Color(0.36, 0.30, 0.22, 1.0)
@export var land_high:     Color = Color(0.62, 0.56, 0.48, 1.0)
@export var desert_color:  Color = Color(0.78, 0.62, 0.38, 1.0)
@export var vegetation_color: Color = Color(0.12, 0.38, 0.14, 1.0)
@export var ice_color:     Color = Color(0.90, 0.95, 1.0, 1.0)
@export var lava_color:    Color = Color(1.0, 0.35, 0.05, 1.0)

@export_group("Palette_Gas")
@export var gas_color_a:      Color = Color(0.86, 0.72, 0.52, 1.0)
@export var gas_color_b:      Color = Color(0.62, 0.42, 0.28, 1.0)
@export var gas_color_c:      Color = Color(0.94, 0.86, 0.72, 1.0)
@export var gas_spot_color:   Color = Color(0.75, 0.32, 0.20, 1.0)
@export var greenhouse_light: Color = Color(0.95, 0.82, 0.55, 1.0)
@export var greenhouse_dark:  Color = Color(0.65, 0.42, 0.22, 1.0)

@export_group("Palette_Effects")
@export var atmosphere_color:   Color = Color(0.45, 0.68, 1.0, 1.0)
@export var twilight_color:     Color = Color(1.0, 0.5, 0.25, 1.0)
@export var cloud_color:        Color = Color(1.0, 1.0, 1.0, 1.0)
@export var city_color:         Color = Color(1.0, 0.82, 0.5, 1.0)
@export var city_day_color:     Color = Color(0.55, 0.55, 0.58, 1.0)
@export var fire_color:         Color = Color(1.0, 0.4, 0.08, 1.0)
@export var lightning_color:    Color = Color(0.75, 0.85, 1.0, 1.0)
@export var life_dot_color:     Color = Color(0.12, 0.08, 0.05, 1.0)


# ─────────────────────────────────────────────────────────────────────────────
# Randomization profiles + helpers
# ─────────────────────────────────────────────────────────────────────────────

# Value spec supports:
# { "range": [min, max] }    -> float range
# { "irange": [min, max] }   -> int range
# { "fixed": value }         -> fixed value (float/int/bool/Color)
# { "bool": true }           -> random boolean
func apply_profile_(rng: RandomNumberGenerator, profile: Dictionary) -> void:
	for prop in profile.keys():
		var spec = profile[prop]
		if typeof(spec) == TYPE_DICTIONARY:
			if spec.has("fixed"):
				set(prop, spec["fixed"])
			elif spec.has("range"):
				var r = spec["range"]
				set(prop, rng.randf_range(r[0], r[1]))
			elif spec.has("irange"):
				var r = spec["irange"]
				set(prop, rng.randi_range(int(r[0]), int(r[1])))
			elif spec.has("bool"):
				set(prop, (rng.randi() % 2) == 0)
		elif typeof(spec) == TYPE_ARRAY and spec.size() >= 2:
			# Treat array as float range for backward compatibility
			set(prop, rng.randf_range(spec[0], spec[1]))
		else:
			set(prop, spec)  # fallback fixed

const BASE_PROFILE := {
	# Planet
	"randomize_params": {"fixed": true},
	"temperature":       {"range": [0.0, 1.0]},
	"ocean_coverage":    {"range": [0.0, 1.0]},
	"atmosphere_density":{"range": [0.0, 1.0]},
	"life_level":        {"range": [0.0, 1.0]},
	"planet_radius":     {"range": [0.3, 1.0]},
	"hue_variation":     {"range": [0.0, 1.0]},
	# Light
	"sensor_level":      {"range": [0.9, 1.0]},
	"light_angle_deg":   {"range": [0.0, 0.0]},
	"light_facing":      {"range": [0.8,0.8]},
	"ambient_light":     {"range": [0.2, 0.3]},
	"exposure":          {"range": [0.5, 1.0]},
	# Motion
	"time_scale":        {"range": [0.0, 0.8]},
	"rotation_speed":    {"range": [-0.3, 0.3]},
	"axial_tilt_deg":    {"range": [-60.0, 60.0]},
	"tilt_variation_deg":{"range": [0.0, 90.0]},
	"cloud_wind":        {"range": [-0.5, 0.5]},
	"hurricane_spin":    {"range": [-3.0, 3.0]},
	"gas_flow_speed":    {"range": [0.0, 2.0]},
	# Terrain
	"terrain_scale":     {"range": [0.5, 8.0]},
	"terrain_octaves":   {"irange": [1, 8]},
	"mountain_amount":   {"range": [0.0, 1.0]},
	"relief":            {"range": [0.0, 3.0]},
	"crater_amount":     {"range": [0.0, 1.0]},
	"lat_gradient":      {"range": [0.0, 1.5]},
	"water_glint":       {"range": [0.0, 2.0]},
	# Gas Giant
	"gas_band_count":    {"range": [2.0, 14.0]},
	"gas_turbulence":    {"range": [0.0, 2.0]},
	# Clouds & Storms
	"cloud_coverage":    {"range": [0.0, 1.0]},
	"cloud_opacity":     {"range": [0.0, 1.0]},
	"cloud_scale":       {"range": [0.5, 8.0]},
	"cloud_octaves":     {"irange": [1, 8]},
	"cloud_shadows":     {"range": [0.0, 1.0]},
	"storm_activity":    {"range": [0.0, 1.0]},
	"lightning_activity":{"range": [0.0, 1.0]},
	# Atmosphere
	"atmo_halo_size":    {"range": [0.0, 0.5]},
	"atmo_halo_strength":{"range": [0.0, 3.0]},
	"atmo_rim_strength": {"range": [0.0, 3.0]},
	"atmo_rim_power":    {"range": [0.5, 8.0]},
	# Civilization
	"city_density":      {"range": [0.0, 1.0]},
	"tech_level":        {"range": [0.0, 1.0]},
	"city_scale":        {"range": [1.0, 10.0]},
	"city_detail":       {"range": [10.0, 120.0]},
	"city_grid_lines":   {"range": [20.0, 240.0]},
	"city_glow":         {"range": [0.0, 4.0]},
	"city_outline":      {"range": [0.0, 2.0]},
	"city_daytime_visibility":{"range": [0.0, 1.0]},
	# Wildfire & Life
	"wildfire_activity": {"range": [0.0, 1.0]},
	"fire_scale":        {"range": [1.0, 12.0]},
	"life_grid":         {"range": [20.0, 160.0]},
	"life_dot_size":     {"range": [0.05, 0.5]},
	"life_dot_opacity":  {"range": [0.0, 1.0]},
	"life_speed":        {"range": [0.0, 4.0]},
	"life_generation_rate":{"range": [0.0, 2.0]},
	# Sensor & Pixelation
	"sensor_gating":     {"bool": true},
	"pixelate_mode":     {"irange": [0, 2]},
	"pixels_min":        {"range": [6.0, 64.0]},
	"pixels_max":        {"range": [32.0, 512.0]},
	"sensor_curve":      {"range": [0.3, 3.0]},
	"fixed_pixels":      {"range": [8.0, 512.0]},
	"sensor_posterize":  {"bool": true},
	"sensor_noise":      {"range": [0.0, 1.0]},
	"sensor_scanlines":  {"range": [0.0, 1.0]},
	# Performance
	"auto_lod":          {"bool": true},
	"lod_min_pixels":    {"range": [4.0, 64.0]},
	"lod_full_pixels":   {"range": [64.0, 1024.0]},
}

const TERRAN_PROFILE := {
	"temperature":        {"range": [0.45, 0.65]},
	"ocean_coverage":     {"range": [0.55, 0.80]},
	"atmosphere_density": {"range": [0.70, 0.90]},
	"life_level":         {"range": [0.40, 0.80]},
	"planet_radius":      {"range": [0.60, 0.95]},
	"cloud_coverage":     {"range": [0.40, 0.70]},
	"cloud_opacity":      {"range": [0.60, 0.95]},
	"terrain_scale":      {"range": [1.2, 3.2]},
	"mountain_amount":    {"range": [0.30, 0.70]},
	"crater_amount":      {"range": [0.10, 0.40]},
}

const GAS_GIANT_PROFILE := {
	"planet_radius":      {"range": [0.85, 1.00]},
	"temperature":        {"range": [0.35, 0.70]},
	"atmosphere_density": {"fixed": 1.0},
	"gas_band_count":     {"range": [7.0, 12.0]},
	"gas_turbulence":     {"range": [0.7, 1.5]},
	"gas_flow_speed":     {"range": [0.8, 2.0]},
	"cloud_coverage":     {"range": [0.70, 1.00]},
	"cloud_opacity":      {"range": [0.80, 1.00]},
	"cloud_scale":        {"range": [3.0, 7.0]},
	"storm_activity":     {"range": [0.40, 0.90]},
	"lightning_activity": {"range": [0.40, 0.90]},
	"life_level":         {"fixed": 0.0},
}

const OCEAN_WORLD_PROFILE := {
	"planet_radius":      {"range": [0.60, 0.95]},
	"temperature":        {"range": [0.40, 0.70]},
	"atmosphere_density": {"range": [0.60, 0.90]},
	"ocean_coverage":     {"range": [0.80, 1.00]},
	"cloud_coverage":     {"range": [0.50, 0.90]},
	"cloud_opacity":      {"range": [0.70, 0.95]},
	"terrain_scale":      {"range": [0.8, 2.0]},
	"mountain_amount":    {"range": [0.10, 0.40]},
	"crater_amount":      {"range": [0.00, 0.30]},
	"life_level":         {"range": [0.20, 0.90]},
}

const ICE_PLUTOID_PROFILE := {
	"planet_radius":      {"range": [0.30, 0.50]},
	"temperature":        {"range": [0.05, 0.25]},
	"atmosphere_density": {"range": [0.02, 0.20]},
	"ocean_coverage":     {"range": [0.00, 0.20]},
	"cloud_coverage":     {"range": [0.00, 0.30]},
	"cloud_opacity":      {"range": [0.10, 0.50]},
	"crater_amount":      {"range": [0.60, 1.00]},
	"relief":             {"range": [0.6, 1.6]},
	"mountain_amount":    {"range": [0.20, 0.50]},
	"life_level":         {"range": [0.00, 0.20]},
}

const BARREN_PROFILE := {
	"planet_radius":      {"range": [0.40, 0.90]},
	"temperature":        {"range": [0.20, 0.60]},
	"atmosphere_density": {"range": [0.00, 0.20]},
	"ocean_coverage":     {"range": [0.00, 0.20]}, # forced to 0 if enforce_type_rules
	"cloud_coverage":     {"range": [0.00, 0.25]},
	"cloud_opacity":      {"range": [0.00, 0.40]},
	"crater_amount":      {"range": [0.50, 1.00]},
	"mountain_amount":    {"range": [0.20, 0.70]},
	"life_level":         {"fixed": 0.0},
}

const GREENHOUSE_PROFILE := {
	"planet_radius":      {"range": [0.60, 1.00]},
	"temperature":        {"range": [0.80, 1.00]},
	"atmosphere_density": {"range": [0.80, 1.00]},
	"ocean_coverage":     {"range": [0.00, 0.60]}, # clamped lower if enforce_type_rules
	"cloud_coverage":     {"range": [0.70, 1.00]},
	"cloud_opacity":      {"range": [0.80, 1.00]},
	"storm_activity":     {"range": [0.40, 0.80]},
	"lightning_activity": {"range": [0.40, 0.80]},
	"life_level":         {"range": [0.00, 0.20]},
}

const ICE_GIANT_PROFILE := {
	"planet_radius":      {"range": [0.80, 1.00]},
	"temperature":        {"range": [0.10, 0.40]},
	"atmosphere_density": {"fixed": 1.0},
	"ocean_coverage":     {"fixed": 0.0},
	"gas_band_count":     {"range": [4.0, 10.0]},
	"gas_turbulence":     {"range": [0.3, 1.2]},
	"gas_flow_speed":     {"range": [0.4, 1.4]},
	"cloud_coverage":     {"range": [0.60, 0.95]},
	"cloud_opacity":      {"range": [0.70, 0.95]},
	"cloud_scale":        {"range": [3.0, 7.0]},
	"storm_activity":     {"range": [0.30, 0.70]},
	"lightning_activity": {"range": [0.20, 0.60]},
	"life_level":         {"fixed": 0.0},
}

# Pick a random concrete type (excluding RANDOM)
func _pick_random_type_(rng: RandomNumberGenerator) -> PlanetType:
	var choices := [
		PlanetType.TERRAN, PlanetType.GAS_GIANT, PlanetType.OCEAN_WORLD,
		PlanetType.ICE_PLUTOID, PlanetType.BARREN, PlanetType.GREENHOUSE,
		PlanetType.ICE_GIANT
	]
	return choices[rng.randi_range(0, choices.size() - 1)]

# Main randomizer: baseline + type profile + rule enforcement (all inside)
func randomize_planet(set_type: PlanetType = PlanetType.RANDOM, use_seed: bool = true) -> void:
	var rng := RandomNumberGenerator.new()

	if use_seed:
		if planet_seed <= 0:
			# Create a seed if not set; keep within [0, 2000]
			planet_seed = int(Time.get_ticks_usec() % 2000)
		rng.seed = int(planet_seed)
	else:
		rng.randomize()

	# Resolve type (RANDOM -> concrete)
	type = _pick_random_type_(rng) if set_type == PlanetType.RANDOM else set_type

	# 1) Apply baseline
	apply_profile_(rng, BASE_PROFILE)

	# 2) Apply type-specific overrides
	match type:
		PlanetType.TERRAN:
			apply_profile_(rng, TERRAN_PROFILE)
		PlanetType.GAS_GIANT:
			apply_profile_(rng, GAS_GIANT_PROFILE)
		PlanetType.OCEAN_WORLD:
			apply_profile_(rng, OCEAN_WORLD_PROFILE)
		PlanetType.ICE_PLUTOID:
			apply_profile_(rng, ICE_PLUTOID_PROFILE)
		PlanetType.BARREN:
			apply_profile_(rng, BARREN_PROFILE)
		PlanetType.GREENHOUSE:
			apply_profile_(rng, GREENHOUSE_PROFILE)
		PlanetType.ICE_GIANT:
			apply_profile_(rng, ICE_GIANT_PROFILE)

	# 3) Enforce hard rules
	if enforce_type_rules:
		match type:
			PlanetType.GAS_GIANT, PlanetType.ICE_GIANT:
				ocean_coverage = 0.0
				mountain_amount = 0.0
				crater_amount = 0.0
			PlanetType.BARREN:
				ocean_coverage = 0.0
			PlanetType.GREENHOUSE:
				ocean_coverage = min(ocean_coverage, 0.30)

	# 4) Optional: vary hue slightly for flavor
	hue_variation = rng.randf_range(0.0, 1.0)


## ───── Utility: push these values onto a ShaderMaterial ──────────────────────
func apply_to(material: ShaderMaterial) -> void:
	if material == null:
		return
	# Planet
	material.set_shader_parameter("planet_seed", planet_seed)
	material.set_shader_parameter("randomize_params", randomize_params)
	material.set_shader_parameter("enforce_type_rules", enforce_type_rules)
	material.set_shader_parameter("temperature", temperature)
	material.set_shader_parameter("ocean_coverage", ocean_coverage)
	material.set_shader_parameter("atmosphere_density", atmosphere_density)
	material.set_shader_parameter("life_level", life_level)
	material.set_shader_parameter("planet_radius", planet_radius)
	material.set_shader_parameter("hue_variation", hue_variation)

	# Light
	material.set_shader_parameter("sensor_level", sensor_level)
	material.set_shader_parameter("light_angle_deg", light_angle_deg)
	material.set_shader_parameter("light_facing", light_facing)
	material.set_shader_parameter("sun_color", sun_color)
	material.set_shader_parameter("ambient_light", ambient_light)
	material.set_shader_parameter("exposure", exposure)

	# Motion
	material.set_shader_parameter("time_scale", time_scale)
	material.set_shader_parameter("rotation_speed", rotation_speed)
	material.set_shader_parameter("axial_tilt_deg", axial_tilt_deg)
	material.set_shader_parameter("tilt_variation_deg", tilt_variation_deg)
	material.set_shader_parameter("cloud_wind", cloud_wind)
	material.set_shader_parameter("hurricane_spin", hurricane_spin)
	material.set_shader_parameter("gas_flow_speed", gas_flow_speed)

	# Terrain
	material.set_shader_parameter("terrain_scale", terrain_scale)
	material.set_shader_parameter("terrain_octaves", terrain_octaves)
	material.set_shader_parameter("mountain_amount", mountain_amount)
	material.set_shader_parameter("relief", relief)
	material.set_shader_parameter("crater_amount", crater_amount)
	material.set_shader_parameter("lat_gradient", lat_gradient)
	material.set_shader_parameter("water_glint", water_glint)

	# Gas Giant
	material.set_shader_parameter("gas_band_count", gas_band_count)
	material.set_shader_parameter("gas_turbulence", gas_turbulence)

	# Clouds & Storms
	material.set_shader_parameter("cloud_coverage", cloud_coverage)
	material.set_shader_parameter("cloud_opacity", cloud_opacity)
	material.set_shader_parameter("cloud_scale", cloud_scale)
	material.set_shader_parameter("cloud_octaves", cloud_octaves)
	material.set_shader_parameter("cloud_shadows", cloud_shadows)
	material.set_shader_parameter("storm_activity", storm_activity)
	material.set_shader_parameter("lightning_activity", lightning_activity)

	# Atmosphere
	material.set_shader_parameter("atmo_halo_size", atmo_halo_size)
	material.set_shader_parameter("atmo_halo_strength", atmo_halo_strength)
	material.set_shader_parameter("atmo_rim_strength", atmo_rim_strength)
	material.set_shader_parameter("atmo_rim_power", atmo_rim_power)

	# Civilization
	material.set_shader_parameter("city_density", city_density)
	material.set_shader_parameter("tech_level", tech_level)
	material.set_shader_parameter("city_scale", city_scale)
	material.set_shader_parameter("city_detail", city_detail)
	material.set_shader_parameter("city_grid_lines", city_grid_lines)
	material.set_shader_parameter("city_glow", city_glow)
	material.set_shader_parameter("city_outline", city_outline)
	material.set_shader_parameter("city_daytime_visibility", city_daytime_visibility)

	# Wildfire & Life
	material.set_shader_parameter("wildfire_activity", wildfire_activity)
	material.set_shader_parameter("fire_scale", fire_scale)
	material.set_shader_parameter("life_grid", life_grid)
	material.set_shader_parameter("life_dot_size", life_dot_size)
	material.set_shader_parameter("life_dot_opacity", life_dot_opacity)
	material.set_shader_parameter("life_speed", life_speed)
	material.set_shader_parameter("life_generation_rate", life_generation_rate)

	# Sensor & Pixelation
	material.set_shader_parameter("sensor_gating", sensor_gating)
	material.set_shader_parameter("pixelate_mode", pixelate_mode)
	material.set_shader_parameter("pixels_min", pixels_min)
	material.set_shader_parameter("pixels_max", pixels_max)
	material.set_shader_parameter("sensor_curve", sensor_curve)
	material.set_shader_parameter("fixed_pixels", fixed_pixels)
	material.set_shader_parameter("sensor_posterize", sensor_posterize)
	material.set_shader_parameter("sensor_noise", sensor_noise)
	material.set_shader_parameter("sensor_scanlines", sensor_scanlines)
	material.set_shader_parameter("unknown_color", unknown_color)

	# Performance
	material.set_shader_parameter("auto_lod", auto_lod)
	material.set_shader_parameter("lod_min_pixels", lod_min_pixels)
	material.set_shader_parameter("lod_full_pixels", lod_full_pixels)

	# Palettes - Rocky
	material.set_shader_parameter("ocean_shallow", ocean_shallow)
	material.set_shader_parameter("ocean_deep", ocean_deep)
	material.set_shader_parameter("land_low", land_low)
	material.set_shader_parameter("land_high", land_high)
	material.set_shader_parameter("desert_color", desert_color)
	material.set_shader_parameter("vegetation_color", vegetation_color)
	material.set_shader_parameter("ice_color", ice_color)
	material.set_shader_parameter("lava_color", lava_color)

	# Palettes - Gas
	material.set_shader_parameter("gas_color_a", gas_color_a)
	material.set_shader_parameter("gas_color_b", gas_color_b)
	material.set_shader_parameter("gas_color_c", gas_color_c)
	material.set_shader_parameter("gas_spot_color", gas_spot_color)
	material.set_shader_parameter("greenhouse_light", greenhouse_light)
	material.set_shader_parameter("greenhouse_dark", greenhouse_dark)

	# Palettes - Effects
	material.set_shader_parameter("atmosphere_color", atmosphere_color)
	material.set_shader_parameter("twilight_color", twilight_color)
	material.set_shader_parameter("cloud_color", cloud_color)
	material.set_shader_parameter("city_color", city_color)
	material.set_shader_parameter("city_day_color", city_day_color)
	material.set_shader_parameter("fire_color", fire_color)
	material.set_shader_parameter("lightning_color", lightning_color)
	material.set_shader_parameter("life_dot_color", life_dot_color)
