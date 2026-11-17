## Base class for all states
class_name StateFarmerQuaryRock
extends State

var chopCount:= 0

func enter(_previous_state_path: StringName, _data := {}) -> void:
	super.enter(_previous_state_path, _data)
	actor.mySprite.play("hammering")
	chopCount = 0
	actor.thoughts.text = "..⭔˖ ࣪⭔"
	if not SignalBus.Timber.is_connected(Timber):
		SignalBus.Timber.connect(Timber)

func update(_delta: float) -> void:
	if actor.mySprite.animation == "hammering" and not actor.mySprite.is_playing():
		chopCount += 1
		SharedData.PlaySound(SharedData.soundEffects[24])
		if chopCount >= 5:
			## remove the tree from the tile
			var map := SharedData.MAP as MapManager
			if map != null:
				var tree_tile: Vector2i = actor.memory.target_position
				#var tree_global := map.objectlayer.to_global(map.objectlayer.map_to_local(tree_tile))
				map.RemoveTree(tree_tile)
				SharedData.PlayEffect(SharedData.effects[0],actor.mySprite.global_position,0,map.effectNode)
				SignalBus.Timber.emit(actor.memory.target_position)
			finished.emit("Idle", {})
			var itm = SharedData.GetItemByName("ROCK")
			actor.cargo.item = itm
			actor.cargo.amount = 1
		else:
			actor.mySprite.play("hammering")

func Timber(pos: Vector2i):
	## if someone else finishes the job in this tile go back to idle
	#print (pos, actor.memory.target_position)
	if pos == actor.memory.target_position:
		finished.emit("Idle", {})
