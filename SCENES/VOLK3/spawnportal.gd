extends AnimatedSprite2D

@export var portalVisual: Sprite2D
@export var progressBar: TextureProgressBar

@export var myTimer: float
@export var timerInterval: float = 0.01

var isActive: bool = false

func _ready() -> void:
	isActive = false
	portalVisual.visible = false
	progressBar.visible = false
	$Control.gui_input.connect(_on_control_gui_input)


func _on_control_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		SharedData.PlaySound(SharedData.soundEffects[5])
		SharedData._screenShake2d(2,0.1)
		isActive = true
		portalVisual.visible = true
		progressBar.visible = true
		progressBar.value +=20


func _process(_deltaTime: float) -> void:
	if progressBar.value <= 0:
		isActive = false
		portalVisual.visible = false
		progressBar.visible = false

	
	if isActive==false : return
	## Update the progress bar based on the timer
	myTimer += _deltaTime
	if myTimer > timerInterval:
		myTimer = 0
		progressBar.value -= 1
		if progressBar.value <0 : progressBar.value = 0
	## Check if the progress bar has reached its maximum value
	if progressBar.value >= progressBar.max_value:
		resetProgressBar()


func resetProgressBar() -> void:
	progressBar.value = 0
	animatePortal()
	SharedData.MAP.SpawnUnit("FARMER", Vector2i(randi_range(-1,1), randi_range(-1,1))) # Replace "unit_id" and Vector2i(0,0) with appropriate values


func animatePortal() -> void:
	SharedData.PlaySound(SharedData.soundEffects[6])
	var originalScale := portalVisual.scale
	var tween := create_tween()
	tween.tween_property(portalVisual, "scale", originalScale * 4.0, 0.1)
	tween.tween_property(portalVisual, "scale", originalScale, 0.1)
	await tween.finished
