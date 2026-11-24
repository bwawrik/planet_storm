class_name MapManager
extends Node2D

@export var terrainlayer: TileMapLayer
@export var objectlayer: TileMapLayer
@export var buildingLayer: TileMapLayer
@export var unitNode : Node2D
@export var mobNode : Node2D
@export var effectNode: Node2D

var unitById: Dictionary = {}

const CARDINAL_OFFSETS: Array[Vector2i] = [
	Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
]
const NEIGHBOR_OFFSETS: Array[Vector2i] = [
	Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
	Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1),
]

# Values are the TileSet source ids.
## terrain indices start at 0
enum Terrain { GRASS = 0, LAVA = 3, WATER = 4}
## object indices start at 1000
enum TerrainObjects { CONIFER = 1000, PINETREE = 1001, OAKTREE = 1002, PALMTREE = 1003, ROCK = 1100 }
## building indices start at 2000
enum BuildingObjects {SPAWNPORTAL = 2000, HOUSE = 2001}

const TREE_OBJECT_IDS: Array[int] = [TerrainObjects.CONIFER, TerrainObjects.PINETREE, TerrainObjects.OAKTREE]

const TERRAIN_PASSABLE := {
	Terrain.GRASS: true,
	Terrain.LAVA: true,
	Terrain.WATER: false,
	TerrainObjects.ROCK: true,
	TerrainObjects.CONIFER: true,
	TerrainObjects.PINETREE: true,
	TerrainObjects.OAKTREE: true,
	TerrainObjects.PALMTREE: true,
	BuildingObjects.SPAWNPORTAL: true,
	BuildingObjects.HOUSE: true,
	
}

const GRASS_NOISE_LAYER := 2
const TREE_NOISE_LAYER := 0
const ROCK_NOISE_LAYER := 1
const SPAWN_RADIUS := 1
const TREE_CLEAR_RADIUS := 4.0
const ROCK_CLEAR_RADIUS := 2.0

var myAstar: AStar2D
var tileIds: Dictionary = {} # Vector2i -> AStar point id
var nextId: int = 0
var structures: Dictionary = {} # Vector2i -> Structure

#region ready 

func _ready() -> void:
	SharedData.MAP = self
	myAstar = AStar2D.new()
	InitMap(60)
	## make a dictionary of units so i can spawn them by name
	for u in SharedData.units: unitById[u.id] = u

func InitMap (n:int) -> void:
	print ('builiding map')
	## first clear everything out
	terrainlayer.clear()
	objectlayer.clear()
	buildingLayer.clear()
	myAstar.clear()
	tileIds.clear()
	nextId = 0

	# Pass order is priority: later passes may overwrite earlier ones.
	var terrain: Dictionary = {} # Vector2i -> Terrain
	var objects: Dictionary = {} # Vector2i -> TreeObj
	_GenerateTerrain(terrain, n)
	_StampTerrain(terrain, Vector2i.ZERO, SPAWN_RADIUS, Terrain.LAVA)
	_ScatterObjects(terrain, objects, TerrainObjects.CONIFER, TREE_NOISE_LAYER, [Terrain.GRASS], TREE_CLEAR_RADIUS)
	_ScatterObjects(terrain, objects, TerrainObjects.ROCK, ROCK_NOISE_LAYER, [Terrain.GRASS], ROCK_CLEAR_RADIUS, 0.1)
	_ApplyToLayers(terrain, objects)

	## add a portal
	buildingLayer.set_cell(Vector2i.ZERO, 0, Vector2i.ZERO, 2000)

#endregion ready

#region map_manipulation

func PlaceStructure(pos: Vector2i, _what: ItemRecipe) -> bool:
	#first check if the position is valid and not already occupied
	if buildingLayer.get_cell_source_id(pos) != -1:
		print("Position already occupied")
		return false
	#check resoruces are abailale by verifying the player has the required items
	var inventory = SharedData.gameManager.inv
	if not _what.CanMake(inventory, null, false):
		print("Not enough resources to make " + _what.name)
		return false
	match _what.name:
		"HOUSE":
			buildingLayer.set_cell(pos, 0, Vector2i.ZERO, 2001)
			# Creates scene tiles now so their Structure registers before the caller looks it up.
			#buildingLayer.update_internals()
			#for ingredient in _what.ingredients:
			#	inventory.RemoveItem(ingredient.item, ingredient.amount)
			UpdateInteranls(pos, _what)
			return true
		"ROAD":
			buildingLayer.set_cell(pos, 0, Vector2i.ZERO, 2002)
			UpdateInteranls(pos, _what)
			return true
		_:
			return false

func UpdateInteranls(pos: Vector2i, _what:ItemRecipe) -> void:
	var inventory = SharedData.gameManager.inv
	buildingLayer.update_internals()
	for ingredient in _what.ingredients:
		inventory.RemoveItem(ingredient.item, ingredient.amount)

func RegisterStructure(s: Structure) -> void:
	structures[s.pos] = s

func UnregisterStructure(s: Structure) -> void:
	if structures.get(s.pos) == s:
		structures.erase(s.pos)

func FindStructureAt(pos: Vector2i) -> Structure:
	return structures.get(pos)

# Grass vs water from noise.
func _GenerateTerrain (terrain: Dictionary, n: int) -> void:
	for x in range(-n+1, n):
		for y in range(-n+1, n):
			if sqrt(x*x + y*y) < n/2:
				terrain[Vector2i(x, y)] = Terrain.GRASS if GetNoise(GRASS_NOISE_LAYER, x, y) > 0 else Terrain.WATER


# Overwrites a square (Chebyshev `radius`) around `center` with `type`.
func _StampTerrain (terrain: Dictionary, center: Vector2i, radius: int, type: Terrain) -> void:
	for x in range(-radius, radius + 1):
		for y in range(-radius, radius + 1):
			terrain[center + Vector2i(x, y)] = type


# Places `obj` with the given probability where noise > 0, on allowed terrain, and outside `clear_radius` of the origin.
func _ScatterObjects (terrain: Dictionary, objects: Dictionary, obj: TerrainObjects, noise_layer: int, allowed_on: Array, clear_radius: float, probability:float = 1.0) -> void:
	for pos in terrain:
		if not allowed_on.has(terrain[pos]):
			continue
		if Vector2(pos).length() <= clear_radius:
			continue
		if GetNoise(noise_layer, pos.x, pos.y) > 0 and (probability >= 1.0 or randf() < probability):
			objects[pos] = obj


func _ApplyToLayers (terrain: Dictionary, objects: Dictionary) -> void:
	for pos in terrain:
		var type: Terrain = terrain[pos]
		var object_type: int = objects.get(pos, -1)
		var passable: bool = TERRAIN_PASSABLE[type] and TERRAIN_PASSABLE.get(object_type, true)
		AddTile(pos, type, passable)
	for pos in objects:
		AddObject(pos, objects[pos])


func GetNoise(n, x, y):
	var _la = SharedData.noiseLayers[n].get_noise_2d(x, y)
	return _la

func AddTile (pos: Vector2i, type: int, passbable : bool) -> void:
	terrainlayer.set_cell(pos,type,Vector2i(randi_range(0,3),0))
	if not passbable:
		return
	if not tileIds.has(pos):
		tileIds[pos] = nextId
		myAstar.add_point(nextId, Vector2(pos))
		nextId += 1
	_ConnectTile(pos)

func AddObject (pos: Vector2i, type: int) -> void:
	objectlayer.set_cell(pos,type,Vector2i(randi_range(0,3),0))


func RemoveTile (pos: Vector2i) -> void:
	terrainlayer.erase_cell(pos)
	if tileIds.has(pos):
		myAstar.remove_point(tileIds[pos])
		tileIds.erase(pos)

func RemoveTree(pos: Vector2i) -> void:
	objectlayer.erase_cell(pos)

#endregion map_manipulation	

# Connects pos to its 8 neighbors. Diagonals are only linked when both
# adjacent orthogonal tiles exist, so units don't cut through corners.
func _ConnectTile (pos: Vector2i) -> void:
	var id: int = tileIds[pos]
	for off in NEIGHBOR_OFFSETS:
		var npos := pos + off
		if not tileIds.has(npos):
			continue
		if off.x != 0 and off.y != 0:
			if not (tileIds.has(pos + Vector2i(off.x, 0)) and tileIds.has(pos + Vector2i(0, off.y))):
				continue
		myAstar.connect_points(id, tileIds[npos])
	# A new tile can complete a diagonal between two existing tiles.
	for off in [Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)]:
		var a: Vector2i = pos + Vector2i(off.x, 0)
		var b: Vector2i = pos + Vector2i(0, off.y)
		if tileIds.has(a) and tileIds.has(b) and tileIds.has(pos + off):
			myAstar.connect_points(tileIds[a], tileIds[b])


# Returns the terrain source id (tile type) at pos, or -1 if there is no tile.
func GetTileType (pos: Vector2i) -> int:
	return terrainlayer.get_cell_source_id(pos)


# Returns tree cells within a Euclidean tile radius of center.
func FindTreesWithin(center: Vector2i, distance: int) -> Array[Vector2i]:
	var found: Array[Vector2i] = []
	if distance < 0:
		return found

	var max_distance_squared := distance * distance
	for x in range(center.x - distance, center.x + distance + 1):
		for y in range(center.y - distance, center.y + distance + 1):
			var cell := Vector2i(x, y)
			var offset := cell - center
			if offset.x * offset.x + offset.y * offset.y > max_distance_squared:
				continue
			if TREE_OBJECT_IDS.has(objectlayer.get_cell_source_id(cell)):
				found.append(cell)
	return found


func FindRocksWithin(center: Vector2i, distance: int) -> Array[Vector2i]:
	var found: Array[Vector2i] = []
	if distance < 0:
		return found

	var max_distance_squared := distance * distance
	for x in range(center.x - distance, center.x + distance + 1):
		for y in range(center.y - distance, center.y + distance + 1):
			var cell := Vector2i(x, y)
			var offset := cell - center
			if offset.x * offset.x + offset.y * offset.y > max_distance_squared:
				continue
			if objectlayer.get_cell_source_id(cell) == TerrainObjects.ROCK:
				found.append(cell)
	return found


func HasTree(pos: Vector2i) -> bool:
	return TREE_OBJECT_IDS.has(objectlayer.get_cell_source_id(pos))


# Path of tile coordinates from `from` to `to`; empty if unreachable.
func FindPath (from: Vector2i, to: Vector2i) -> PackedVector2Array:
	if not tileIds.has(from) or not tileIds.has(to):
		return PackedVector2Array()
	return myAstar.get_point_path(tileIds[from], tileIds[to])

func IsWalkable(pos: Vector2i) -> bool:
	return tileIds.has(pos)


# Walkable tiles within a Euclidean tile radius of center, excluding center.
func FindWalkableWithin(center: Vector2i, distance: int) -> Array[Vector2i]:
	var found: Array[Vector2i] = []
	for cell in _CellsWithin(center, distance):
		if cell != center and tileIds.has(cell):
			found.append(cell)
	return found


# Walkable tiles with no tree on them or on any of their N/S/E/W neighbors.
func FindClearSpotsWithin(center: Vector2i, distance: int) -> Array[Vector2i]:
	var found: Array[Vector2i] = []
	for cell in FindWalkableWithin(center, distance):
		if _IsClearSpot(cell):
			found.append(cell)
	return found


func _IsClearSpot(pos: Vector2i) -> bool:
	if HasTree(pos):
		return false
	for off in CARDINAL_OFFSETS:
		if HasTree(pos + off):
			return false
	return true


func _CellsWithin(center: Vector2i, distance: int) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	var max_distance_squared := distance * distance
	for x in range(center.x - distance, center.x + distance + 1):
		for y in range(center.y - distance, center.y + distance + 1):
			var offset := Vector2i(x, y) - center
			if offset.x * offset.x + offset.y * offset.y <= max_distance_squared:
				cells.append(Vector2i(x, y))
	return cells

#region unit_management

func SpawnUnit(id: StringName, tile: Vector2i) -> Node2D:
	var unit = unitById[id].scene.instantiate()
	var tile_global := terrainlayer.to_global(terrainlayer.map_to_local(tile))
	unit.position = unitNode.to_local(tile_global)
	 
	unitNode.add_child(unit)
	return unit

func HasSelectedUnits() -> bool:
	var units = unitNode.get_children()
	for u in units:
		if u.selected and u.selected ==true:
			return true
	return false

func GetSelectedUnits():
	var units = unitNode.get_children()
	var selected_units=[]
	for u in units:
		if u.selected and u.selected ==true:
			selected_units.append(u)
	return selected_units
	
func FindNearestTotem(pos: Vector2i) -> Variant:
	var effects = effectNode.get_children()
	var nearest: Variant = null
	var nearest_distance = INF
	for e in effects:
		if e is Totem:
			var e_tile: Vector2i = e.tile_position
			var dist := (e_tile - pos).length_squared()
			if dist < nearest_distance:
				nearest_distance = dist
				nearest = e_tile
	return nearest

func FindTotemAt(pos: Vector2i) -> Totem:
	var effects = effectNode.get_children()
	for e in effects:
		if e is Totem:
			if e.tile_position == pos: return e
	return null
	
#endregion unit_management
