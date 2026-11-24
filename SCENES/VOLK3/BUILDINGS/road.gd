extends Structure
class_name structure_road

func increment_construction_stage() -> void:
	super()
	## when done constucting; delete sprite and sreplace the map tile to a gravel tile
	if is_complete == true:
		#set tilemap to gravel
		SharedData.MAP.AddTile(pos,1,true)
		queue_free()
