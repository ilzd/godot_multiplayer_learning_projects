extends StaticBody2D

const SPEED := 300.0


func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())


func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		var direction = Input.get_axis("move_up", "move_down")
		position.y += direction * SPEED * delta
		position.y = clamp(position.y, 50, 550)
