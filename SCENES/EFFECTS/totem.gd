extends Node2D

var startPos: Vector2
var endPos: Vector2
var lifetime: float = 20
var item: InventoryItem

var tm: float = 0

func _init() -> void:
	visible = false
	
func displayTotem(epos: Vector2, itm: InventoryItem) -> void:
	$totem_sprite.texture = itm.texture
	endPos = epos
	startPos = epos + Vector2.UP * 500
	position = startPos
	visible = true

	var tween := create_tween()
	tween.tween_property(self, "position", endPos, 0.2)
	tween.tween_callback(func() -> void: SharedData._screenShake2d(2.0, 0.1))
	SharedData.PlaySound(SharedData.soundEffects[22])
	tween.tween_callback(_start_bobbing)
	

func _start_bobbing() -> void:
	var bob_tween := create_tween().set_loops()
	bob_tween.tween_property(self, "position:y", endPos.y - 10.0, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	bob_tween.tween_property(self, "position:y", endPos.y, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		var sprite := $totem_sprite as Sprite2D
		var local_mouse_position = sprite.get_global_transform_with_canvas().affine_inverse() * event.position
		if sprite.get_rect().has_point(local_mouse_position):
			queue_free()

func _process(delta: float) -> void:
	tm += delta
	if tm > lifetime: 
		queue_free()
	
