## The "items" that exist within the game.
class_name InventoryItem extends Resource

#region Declarations
@export var name : StringName = &""
@export var description: StringName = &""
@export var value : int = 1
@export var texture : Texture
@export var purchaseable : bool = false
@export var type: Genum.item_type
#endregion
