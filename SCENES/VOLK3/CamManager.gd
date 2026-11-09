extends Camera2D

@export var myCam: Camera2D
@export var camMovementSpeed: int = 700

var startPos: Vector2
var screenEdgeMovementAllowed: bool = true

func _init() -> void:
	SharedData.myCam = self
	myCam = SharedData.myCam 
	SignalBus.CircleMenuVisible.connect(BlockScreenEdgeMovement)
	
	## homing signal
	startPos = position
	SignalBus.TextSignal.connect(ReturnHome)

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if Input.is_action_pressed("left"):
		position.x -= delta * camMovementSpeed
	if Input.is_action_pressed("right"):
		position.x += delta * camMovementSpeed
	if Input.is_action_pressed("up"):
		position.y -= delta * camMovementSpeed
	if Input.is_action_pressed("down"):
		position.y += delta * camMovementSpeed
	
	if Input.is_action_just_released("zoomOut"):
		if myCam.zoom.x > 0.5:
			myCam.zoom =  myCam.zoom - Vector2(0.1, 0.11)
	if Input.is_action_just_released("zoomIn"):
		if myCam.zoom.x < 1:
			myCam.zoom =  myCam.zoom + Vector2(0.1, 0.11)

	move_camera_on_edge()
	
func CenterCameraOn(P):
	set_global_position(P - get_viewport_rect().size / 2)


func move_camera_on_edge():
	
	if screenEdgeMovementAllowed == false: return
	
	var viewport_size = get_viewport().size
	var mouse_pos = get_viewport().get_mouse_position()
	var move_distance = 3
	
	if mouse_pos.x < 5 and mouse_pos.x > -100:
		myCam.position.x -= move_distance
	elif mouse_pos.x > viewport_size.x - 5 and mouse_pos.x < viewport_size.x + 100:
		myCam.position.x += move_distance
	
	if mouse_pos.y < 5 and mouse_pos.y > -100:
		myCam.position.y -= move_distance
	elif mouse_pos.y > viewport_size.y - 5 and mouse_pos.y < viewport_size.y + 100:
		myCam.position.y += move_distance


func BlockScreenEdgeMovement(canMove, what) -> void:
	#print (canMove, what)
	screenEdgeMovementAllowed = !canMove
	return

func ReturnHome(s) -> void:
	if s == "Return To Home":
		position = startPos
	
