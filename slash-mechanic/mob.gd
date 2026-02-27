extends CharacterBody2D

var health: int = 100


func _enter_tree() -> void:
	set_multiplayer_authority(1)


@rpc("any_peer", "call_local")
func receive_damage(amount: int):
	if not is_multiplayer_authority(): return
	
	health -= amount
	print(name, " took ", amount, " damage! Health: ", health)
	
	$ColorRect.color = Color.WHITE
	await get_tree().create_timer(0.1).timeout
	$ColorRect.color = Color.RED
	
	if health < 0:
		position = Vector2(randi_range(50, 550), randi_range(50, 550))
