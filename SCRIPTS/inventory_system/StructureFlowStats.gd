extends Resource
class_name StructureFlowStats

## base rates for one structure type; assign a shared .tres per building on its scene
@export var production: Array[ResourceFlow] = []
@export var consumption: Array[ResourceFlow] = []
