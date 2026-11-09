class_name MapManager
extends Node2D

@export var terrainlayer: TileMapLayer
@export var objectlayer: TileMapLayer
@export var specialTilesLayer: TileMapLayer
@export var unitNode : Node2D
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
enum Terrain { GRASS = 0, LAVA = 3, WATER = 4 }
enum TreeObj { CONIFER = 0, PINETREE = 1, OAKTREE = 2 }
const TREE_OBJECT_IDS: Array[int] = [TreeObj.CONIFER, TreeObj.PINETREE, TreeObj.OAKTREE]

const TERRAIN_PASSABLE := {
	Terrain.GRASS: true,
	Terrain.LAVA: true,
	Terrain.WATER: false,
}
const GRASS_NOISE_LAYER := 2
const TREE_NOISE_LAYER := 0
const SPAWN_RADIUS := 1
const TREE_CLEAR_RADIUS := 4.0



var myAstar: AStar2D
var tileIds: Dictionary = {} # Vector2i -> AStar point id
var nextId: int = 0

func _ready() -> void:
	SharedData.MAP = self
	myAstar = AStar2D.new()
	InitMap(10)
	## make a dictionary of units so i can spawn them by name
	for u in SharedData.units: unitById[u.id] = u


# Path of tile coordinates from `from` to `to`; empty if unreachable.
func FindPath (from: Vector2i, to: Vector2i) -> PackedVector2Array:
	if not tileIds.has(from) or not tileIds.has(to):
		return PackedVector2Array()
	return myAstar.get_point_path(tileIds[from], tileIds[to])


func InitMap (n:int) -> void:
	print ('builiding map')
	## first clear everything out
	terrainlayer.clear()
	objectlayer.clear()
	specialTilesLayer.clear()

	# Pass order is priority: later passes may overwrite earlier ones.
	var terrain: Dictionary = {} # Vector2i -> Terrain
	var objects: Dictionary = {} # Vector2i -> TreeObj
	_GenerateTerrain(terrain, n)
	_StampTerrain(terrain, Vector2i.ZERO, SPAWN_RADIUS, Terrain.LAVA)
	_ScatterObjects(terrain, objects, TreeObj.CONIFER, TREE_NOISE_LAYER, [Terrain.GRASS], TREE_CLEAR_RADIUS)
	_ApplyToLayers(terrain, objects)


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


# Places `obj` where noise > 0, on allowed terrain, and outside `clear_radius` of the origin.
func _ScatterObjects (terrain: Dictionary, objects: Dictionary, obj: TreeObj, noise_layer: int, allowed_on: Array, clear_radius: float) -> void:
	for pos in terrain:
		if not allowed_on.has(terrain[pos]):
			continue
		if Vector2(pos).length() <= clear_radius:
			continue
		if GetNoise(noise_layer, pos.x, pos.y) > 0:
			objects[pos] = obj


func _ApplyToLayers (terrain: Dictionary, objects: Dictionary) -> void:
	for pos in terrain:
		var type: Terrain = terrain[pos]
		AddTile(pos, type, TERRAIN_PASSABLE[type])
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


func HasTree(pos: Vector2i) -> bool:
	return TREE_OBJECT_IDS.has(objectlayer.get_cell_source_id(pos))


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


func SpawnUnit(id: StringName, tile: Vector2i) -> Node2D:
	var unit = unitById[id].scene.instantiate()
	var tile_global := terrainlayer.to_global(terrainlayer.map_to_local(tile))
	unit.position = unitNode.to_local(tile_global)
	 
	unitNode.add_child(unit)
	return unit

func HasSelectedUnits() -> bool:
	var units = $UnitNode.get_children()
	for u in units:
		if u.selected and u.selected ==true:
			return true
	return false
