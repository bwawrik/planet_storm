#extends AudioStreamPlayer2D
extends Node  #keeping this as node2d, so i can have my own play boolean

var delay = 0.0
var playing = false
	
func _ready():
	pass

func _process(deltaTime):
	if playing == true:
		delay -=deltaTime
		if delay < 0:
			$".".play()	
			playing = false
		
func SetSound(myStream):
	$".".stream = myStream

func SetDelay (t):
	delay = t
	

func Play():
	#$".".play()
	#print('playing:', $".".stream)
	playing = true


func _on_finished():
	#print("Sound has finished playing")
	queue_free()
