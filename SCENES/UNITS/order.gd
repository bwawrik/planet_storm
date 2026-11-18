class_name Order
extends RefCounted

# Resource-focused work an order can repeat at its anchor.
# MINE uses preferred_target to distinguish rocks from other mineable resources.
enum ResourceType {NONE, TREES, ROCKS, MINE}

# The active work type, or NONE when the unit has no resource-specific order.
var resource_type: ResourceType = ResourceType.NONE
# Center tile for this order, set by the player's right-click.
var anchor_position: Vector2i = Vector2i.ZERO
# Maximum distance from the anchor when looking for another matching resource.
var search_radius: int = 10
# Resource to work on for orders that can target more than one resource type.
var preferred_target: ResourceType = ResourceType.NONE
