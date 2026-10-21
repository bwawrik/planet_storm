extends Node2D
@export var mySprite: AnimatedSprite2D
@export var text1: RichTextLabel
@export var text2: RichTextLabel

var target_position: Vector2
var speed := 5000.0  # pixels per second

var achievement: Achievement 

func _ready():
	# Start off-screen to the right
	var screen_size = DisplayServer.window_get_size() # DisplayServer.screen_get_size()
	position.x = screen_size.x + 100
	position.y = -300 #screen_size.y / 2

	# Define center of screen
	target_position = Vector2(screen_size.x/2, -300)

	# Start moving
	set_process(true)

func setAchievement(n) -> void:
	achievement = SharedData.achievement[n]
	mySprite.frame = achievement.imageID
	text1.text = achievement.achievement_text
	text2.text = achievement.achievement_unlock

func _process(delta):
	# Move toward center
	var direction = (target_position - position).normalized()
	
	position += direction * speed * delta

	# Check if close enough to stop
	if position.distance_to(target_position) < 100:
		position = target_position
		set_process(false)
		# Wait 1 second, then free
		$AnimatedSprite2D/GPUParticles2D.emitting = true
		SharedData.myCam.shake(delta)
		SharedData.PlaySound(SharedData.soundEffects[14])
		await get_tree().create_timer(4.0).timeout
		queue_free()
