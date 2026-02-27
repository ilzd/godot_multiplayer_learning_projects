extends Node2D

var pierce_limit: int = 1
var hit_count: int = 0
var damaged_targets: Array = []

var is_authority: bool = false
var attacker_id: int = 1


func _ready() -> void:
	$Hitbox.body_entered.connect(_on_hitbox_body_entered)
	
	if not is_authority:
		$Hitbox/CollisionShape2D.disabled = true
	
	rotation_degrees += 80
	var tween = create_tween()
	tween.tween_property(self, "rotation_degrees", rotation_degrees - 160, 0.15)
	
	tween.tween_callback(queue_free)


func _on_hitbox_body_entered(body: Node2D):
	if not is_authority: return
	
	if body.name == str(attacker_id) or body in damaged_targets:
		return
	
	if body.is_in_group("mobs") or body.is_in_group("players"):
		damaged_targets.append(body)
		
		var target_auth = body.get_multiplayer_authority()
		body.receive_damage.rpc_id(target_auth, 25)
		
		hit_count += 1
		
		if hit_count > pierce_limit:
			queue_free()
