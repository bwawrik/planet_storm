## Base class for all states
class_name StateNode extends Node

## parent node with decorations
var actor: Node

## Emitted when the state finishes and wants to transition to another state.
signal finished(next_state_path: StringName, data: Dictionary)


## Called by the state machine upon changing the active state to this one. The 'data' parameter
## is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_previous_state_path: StringName, _data := {}) -> void:
	finished.connect(_finished)
	#actor.myAnimationPlayer.play("idle")
	pass
	
func _ready() -> void:
	#connect singlas here
	#SignalBus.narration_closed.connect(_done)
	pass

## Called by the state machine when receiving unhandled input events.
func handle_input(_event: InputEvent) -> void:
	pass

## Called by the state machine on the engine's main loop tick.
func update(_delta: float) -> void:
	pass
	#if SharedData.rStick.x !=0 or SharedData.rStick.y !=0:	emit_signal("finished", "walk", {})
		
## Called by the state machine on the engine's physics update tick.
func physics_update(_delta: float) -> void:
	pass

## Called by the state machine before changing the active state to the next one. Use this function
## to clean up the state.
func exit() -> void:
	pass

func _finished():
	pass
