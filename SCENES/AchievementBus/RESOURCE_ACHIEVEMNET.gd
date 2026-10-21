extends Resource

class_name Achievement

@export var achievement_name: String
@export var achievement_text: String
@export var achievement_unlock: String
@export var imageID: int

func Changed():
	emit_changed()
