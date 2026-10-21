extends Node

var achievement_bus = {}
var achievements_unlocked = {}
var achievement_timer: float = 2

#@onready var achieve   = preload("res://SCENES/AchievementBus/achievement.tscn")
#
#func _ready() -> void:
	#SignalBus.connect("killed_unit", _KilledUnit)
#
#func _process(_deltaTime: float) -> void:
		#_ManageAchievements(_deltaTime)
#
#func AddAchievement(type):
	### if the achievement is nto unlocked, add to bus; otherwise add to unlocked counter
	#if type not in achievements_unlocked:
		#achievement_bus[type] = 1
	#else:
		#achievements_unlocked[type] = achievements_unlocked[type] + 1
		#
#func TriggerAchievement(n):
	#var na = achieve.instantiate()
	#na.setAchievement(n)
	#SharedData.effectNode.add_child(na)
#
#func _KilledUnit(type):
	#AddAchievement(type)
#
#func _ManageAchievements(_deltaTime: float) -> void:
	#achievement_timer -= _deltaTime
	#if achievement_timer < 0:
		#achievement_timer = 2
		#if not achievement_bus.is_empty():
			#var busKey = achievement_bus.keys()[0]
			##for type in achievement_bus.keys():
			#if busKey == "Bear":
				#SignalBus.new_card.emit("Bear")
				#TriggerAchievement(0)
				#achievements_unlocked[busKey] = 1
				#achievement_bus.erase(busKey)
				#SharedData.isCardUnlocked[2] = true  #unlock tower card
	#pass
	#
