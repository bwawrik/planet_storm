## A simple, but flexible StateMachine.
## attach this to a statemachien node; make sub-nodes with each of the states
#character.tscn (inherits CharacterBody2D)
#├── AnimationPlayer
#├── CollisionShape2D
#├── Polygon2D (Eye)
#├── StateMachine (Node) ← attach `StateMachine.gd` here
#│   ├── IdleState (Node) ← attach `IdleState.gd` here
#│   ├── MoveState (Node) ← attach `MoveState.gd` here

class_name StateMachine extends Node

#region Variables
@export var initial_state: State = null
var actor: CharacterBody2D

## Defines the current state by either grabbing the first child or if [property initial_state] is set.
@onready var state: State = (func _get_initial_state() -> State:
	return initial_state if initial_state != null else get_child(0)
).call()
#endregion

#region Built-Ins
func _ready() -> void:
	actor = get_parent()  # This is your Knight, which inherits CharacterBody2D
	for state_node: State in find_children("*", "State"):
		state_node.finished.connect(_transition_to_next_state)
	
	await owner.ready
	state.actor = actor
	state.enter("")


func _process(delta: float) -> void:
	print("Current state is: ", state.name)
	state.update(delta)

func _physics_process(delta: float) -> void:
	state.physics_update(delta)

func _unhandled_input(event: InputEvent) -> void:
	state.handle_input(event)
#endregion

#region Helpers
## Handles transitioning between [property state] and [param target_state_path]. Can also pass a
## dictionary [param data] to provide additional information to the new state.
func _transition_to_next_state(target_state_path: String, data := {}) -> void:
	if not has_node(target_state_path):
		printerr(owner.name + ": Trying to transition to state " + target_state_path + " but it does not exist.")
		return
	
	var previous_state_path := state.name
	state.exit()
	state = get_node(target_state_path)
	state.actor = actor ## set node with decorations
	state.enter(previous_state_path, data)
#endregion
