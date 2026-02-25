extends Node
class_name StatusEffect

@export var duration = 0.0
var target: Node

func _ready():
	target = get_parent().get_parent()
	
	if multiplayer.is_server():
		apply_effect()
		if duration > 0:
			var timer = get_tree().create_timer(duration)
			timer.timeout.connect(_on_timeout)


func apply_effect():
	pass


func remove_effect():
	pass


func _on_timeout():
	remove_effect()
	queue_free()


func _exit_tree() -> void:
	remove_effect()
