extends Area2D

const SPEED = 600.0
var lifespan = 2.0
var shooter_id = 0


func _physics_process(delta: float) -> void:
	position += transform.x * SPEED * delta
	
	lifespan -= delta
	if lifespan <= 0:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("players"):
		if body.name != str(shooter_id):
			
			if multiplayer.get_unique_id() == shooter_id:
				body.take_damage.rpc_id(body.name.to_int(), 10)
			
			queue_free()
