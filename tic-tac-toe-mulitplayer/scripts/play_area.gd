extends Area2D
class_name PlayArea

signal area_played(x: int, y: int)

var x: int
var y: int


func set_coords(cx: int, cy: int):
	x = cx
	y = cy


func _on_mouse_entered() -> void:
	$ColorRect.color = Color("ffffff7f")


func _on_mouse_exited() -> void:
	$ColorRect.color = Color("ffffff40")

func set_symbol(symbol: String):
	$PlayerLabel.text = symbol


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event.is_pressed():
		area_played.emit(x, y)
