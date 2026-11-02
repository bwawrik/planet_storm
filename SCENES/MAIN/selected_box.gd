extends Sprite2D

var hasSelection: bool = false

func _ready() -> void:
	hasSelection = false
	visible = false
	SignalBus.UnselectAll.connect(_unselect)
		
func _unselect() ->void:
	visible = false
