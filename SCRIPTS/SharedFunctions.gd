extends Node

func ShowToolTip(s) -> void:
	SharedData.showTooltips = true
	SharedData.mouseIcon._ToolTipText(s)

func HideToolTip() -> void:
	SharedData.showTooltips = false
	
## get all children recursively
func get_all_descendants(node: Node, result := []):
	for child in node.get_children():
		result.append(child)
		get_all_descendants(child, result)
	return result


func CheckCost(T) -> bool:
	# returns true if resources are available
	if T.stats.woodCost > SharedData.wood: return false
	if T.stats.manaCost > SharedData.wood: return false
	if T.stats.wheatCost > SharedData.wood: return false
	return true

func Seconds2Minutes(time: int) -> String:
	var minutes: int = floor(time / 60)
	var seconds: int = time % 60
	return "%02d:%02d" % [minutes, seconds]
	
func Sum(arr):
	var tot = 0
	for n in arr:
		tot+=n
	return tot
