extends Resource
class_name StructureFlowModifier

enum Target { PRODUCTION, CONSUMPTION }
enum Mode { ADD, MULTIPLY }

@export var vtex: int
@export var target_type: StringName = &"" # e.g. HAB; FARM
@export var item: InventoryItem            ## null = applies to every resource in the target list
@export var target: Target = Target.PRODUCTION
@export var mode: Mode = Mode.MULTIPLY
@export var value: float = 1.0
