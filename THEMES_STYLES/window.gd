@tool
extends Window

func _ready():
	call_deferred("_apply_layout")
	transparent_bg = true

func _apply_layout():
	var nine =$NinePatchRect
	nine.anchor_left = 0
	nine.anchor_top = 0
	nine.anchor_right = 1
	nine.anchor_bottom = 1

	nine.offset_left = 0
	nine.offset_top = 0
	nine.offset_right = 0
	nine.offset_bottom = 0


func _on_close_requested() -> void:
	get_parent().queue_free()
