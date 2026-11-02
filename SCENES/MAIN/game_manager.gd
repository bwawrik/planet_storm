extends Node

var gameStart: bool = true

func _ready() -> void:
	## on startup create a star
	if gameStart:
		SignalBus.StartGame.emit()
		gameStart = false
		
		
