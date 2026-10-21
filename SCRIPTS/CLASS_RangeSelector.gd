class_name RangeSelector

var position: int = 0
var maxValue: int = 2
var minValue: int = 0


func _init(low: int, high: int) -> void:
	minValue = low
	maxValue = high

func GetPosition()-> int: return position
func SetPosition(new_position: int): position = clamp(new_position, 0, maxValue)

func Next():
	position += 1
	if position > maxValue:
		position = 0

func Previous():
	position -= 1
	if position < 0:
		position = maxValue

func PredictNext() -> int:
	Next()
	var isnext = position
	Previous()
	return isnext

func PredictPrevious() -> int:
	Previous()
	var isprior = position
	Next()
	return isprior


func SetMax(val): maxValue = val
func GetMax() -> int: return maxValue
func SetMin(low): minValue = low
func GetMin() -> int: return minValue
