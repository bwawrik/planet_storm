extends GameWindow


func _on_start_pressed() -> void:
	SceneManager.call_deferred("change_scene", "Start Game")


func _on_quit_pressed() -> void:
	get_tree().quit()
