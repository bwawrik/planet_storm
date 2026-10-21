extends Node

#region settings
@export var isPaused: bool = true
@export var showTooltips: bool = false
@export var allowTooltips: bool = true
@export var allowConsole: bool = true
#endregion

#region environment
## environment
#@export var PlayerNode: CharacterBody2D
@export var UINode: CanvasLayer
@export var myCam:Camera2D
@export var effectNode: Node
#endregion

#region sound
## sounds and effects
@export var musicManager: MusicManager
@export var musicTracks: Array[AudioStream]
@export var soundEffects: Array[AudioStream] 
#endregion

#region scenes
@onready var sfx_scene = preload("res://SCENES/SoundEffect.tscn")
@export var effects: Array[PackedScene]
#endregion

#region Inventory

@export var myInventory: Inventory

#region achievement bus
var achievement_bus = {}
var achievements_unlocked = {}
#endregion

#region input
@export var rStick: Vector2
@export var lStick: Vector2
#@export var mouseIcon: Node2D
var mouse_screen_pos: Vector2 
var mouse_global_pos: Vector2 
var screenSize: Vector2
var pads
var pad_id
#endregion

#region functions
func _enter_tree():

	## find screensize
	screenSize = get_viewport().get_visible_rect().size

	## set up gamepads
	pads = Input.get_connected_joypads()
	if pads.size()>0: pad_id = pads[0]
	else: pad_id =0

	## add the music manager
	if not musicManager:
		musicManager = MusicManager.new()
		add_child(musicManager)
	## add the inventory (if needed)
	if not myInventory: 
		myInventory= Inventory.new()

func _ready() -> void:
	#SignalBus.connect("narrative", _narrativeLine)
	## make audiostreamplayers for immdiate playback
	_InitianteSoundPool()


func _process(_deltaTime: float) -> void:
		
	var x_axis = Input.get_joy_axis(pad_id, JOY_AXIS_RIGHT_X)
	var y_axis = Input.get_joy_axis(pad_id, JOY_AXIS_RIGHT_Y)
	if abs(x_axis) < 0.0001: x_axis = 0
	if abs(y_axis) < 0.0001: y_axis = 0
	rStick = Vector2(x_axis, y_axis)
	x_axis = Input.get_joy_axis(pad_id, JOY_AXIS_LEFT_X)
	y_axis = Input.get_joy_axis(pad_id, JOY_AXIS_LEFT_Y)
	if  abs(x_axis) < 0.0001: x_axis = 0
	if abs(y_axis) < 0.0001: y_axis = 0
	lStick = Vector2(x_axis, y_axis)

	## keyboard override of controller
	if Input.is_action_pressed("left"): lStick.x = -1
	if Input.is_action_pressed("right"): lStick.x = 1
	if Input.is_action_pressed("forward"): lStick.y = -1
	if Input.is_action_pressed("backward"): lStick.y = 1
	


	#get the local, global, and grid position of the mouse; this is needed for UI stuff
	mouse_screen_pos = get_viewport().get_mouse_position()
	mouse_global_pos = get_viewport().get_canvas_transform().affine_inverse() * mouse_screen_pos

	# check if paused
	if SharedData.isPaused: return

#region Movement

var DEADZONE := 0.2 
func lstick_zero() -> bool: return lStick.length() < DEADZONE
func rstick_zero() -> bool: return rStick.length() < DEADZONE

var lastDirection: String = "down"

func get_direction_name(vec: Vector2) -> String:
	var ret: String = lastDirection
	if vec == Vector2.ZERO: return ret
	var angle = vec.angle()
	# 8-way split (45° each)
	if angle < -2.748 or angle > 2.748: 	ret = "left"
	elif angle < -1.963:					ret = "up_left"
	elif angle < -1.178:					ret = "up"
	elif angle < -0.393:					ret = "up_right"
	elif angle < 0.393:					ret = "right"
	elif angle < 1.178:					ret = "down_right"
	elif angle < 1.963:					ret = "down"
	else:								ret = "down_left"
	lastDirection = ret
	return ret
	
const DIR_MAP = {
	"up":         {"base": "up",          "flip": false},
	"up_right":   {"base": "up_right",    "flip": false},
	"right":      {"base": "right",       "flip": false},
	"down_right": {"base": "down_right",  "flip": false},
	"down":       {"base": "down",        "flip": false},
	"down_left":  {"base": "down_right",  "flip": true},
	"left":       {"base": "right",       "flip": true},
	"up_left":    {"base": "up_right",    "flip": true},
}
#endregion


#region SoundPool
const SOUND_POOL_SIZE := 32
var soundPool: Array[AudioStreamPlayer] = []

func PlaySound(stream, _bus=null, _volume= 0):
	#set up sound pool on first call
	if soundPool.size() == 0 : _InitianteSoundPool()
	var p = _getAvailableSoundPlayer()
	print (p)
	p.stream = stream
	if _bus != null: p.bus = _bus
	p.volume_db = _volume
	p.play()

func _InitianteSoundPool():
	for i in range (SOUND_POOL_SIZE):
		var p = AudioStreamPlayer.new()
		p.bus = "SFX"
		p.autoplay = false
		p.stream_paused = false
		add_child(p)
		soundPool.append(p)

func _getAvailableSoundPlayer() -> AudioStreamPlayer:
	for p in soundPool:
		if not p.playing:
			return p
	# fallback: steal the first one
	return soundPool[0]


#endregion 


#func PlaySound(effect, _bus=null, _parent=null, _volume= 0, _soundDelay=0):
	#var newSound = sfx_scene.instantiate()
	#if _parent == null:
		#get_tree().root.add_child(newSound)
	#else:
		#_parent.add_child(newSound)
	#if _bus != null: newSound.bus = _bus
	#newSound.SetSound(effect)  #soundEffects[n]
	#newSound.SetDelay(_soundDelay)
	#newSound.volume_db = _volume
	#newSound.Play()
	#return newSound
#region Effects

func PlayEffect(effect, pos, _delay=0, _parent=null) -> bool:
	var ne = effect.instantiate()
	if _delay != 0:
		ne.SetDelay(_delay)
	ne.position = pos
	if _parent == null:
		effectNode.add_child(ne)
	else:
		_parent.add_child(ne)
	return true

func _screenShake2d(strength: float, duration: float) -> void:
	if SharedData.myCam:
		var elapsed = 0.0
		var original_position = SharedData.myCam.global_position
		while elapsed < duration:
			elapsed += get_physics_process_delta_time()
			SharedData.myCam.global_position = original_position + Vector2(randf_range(-strength, strength), randf_range(-strength, strength))
			await get_tree().process_frame
		SharedData.myCam.global_position = original_position
		
func _screenShake3d(strength: float, duration: float) -> void:
	if SharedData.myCam:
		var elapsed = 0.0
		var original_position = SharedData.myCam.global_position
		while elapsed < duration:
			elapsed += get_physics_process_delta_time()
			var offset = Vector3(randf_range(-strength, strength), randf_range(-strength, strength), randf_range(-strength, strength))
			SharedData.myCam.global_position = original_position + offset
			await get_tree().process_frame
		SharedData.myCam.global_position = original_position


#endregion
