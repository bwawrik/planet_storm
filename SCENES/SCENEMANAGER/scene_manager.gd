extends Node

#uncomment next line if declared in some other script; i usually add this to a scene that I add to the globals; there is more than one way to go to Rome.
#class_name SceneManager


var current_scene: Node = null

func _ready() -> void:
	pass

func change_scene(scene_path: String):
	if current_scene:
		current_scene.queue_free()
	if scene_path == "Main Menu": scene_path = "res://SCENES/MENU.tscn"
	if scene_path == "Start Game": scene_path ="res://SCENES/MAIN/LEVEL_1.tscn" 
	
	var new_scene = load(scene_path).instantiate()
	$".".add_child(new_scene)
	current_scene = new_scene
