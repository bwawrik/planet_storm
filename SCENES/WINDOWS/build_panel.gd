extends Control
class_name BuildPanel

@onready var recipe_icon: TextureRect = $MarginContainer/recipe_icon

@export var recipe: ItemRecipe

func _ready() -> void:
	ClearRecipe()
	SignalBus.BuildRecipeSelected.connect(SetRecipe)

func SetRecipe(r):
	recipe=r
	recipe_icon.texture = r.item.texture
	
func ClearRecipe():
	recipe = null
	recipe_icon.texture = null
	
