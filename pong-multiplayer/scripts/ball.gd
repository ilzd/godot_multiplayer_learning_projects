extends CharacterBody2D

const START_SPEED = 400.0
var speed = START_SPEED
var direction = Vector2.ZERO

@export var sync_position: Vector2


func _enter_tree() -> void:
	set_multiplayer_authority(1)
	sync_position = global_position


func _ready() -> void:
	global_position = sync_position
 

func reset_ball():
	speed = START_SPEED
	
	var random_x = [-1, 1].pick_random()
	var random_y = randf_range(-0.5, 0.5)
	direction = Vector2(random_x, random_y).normalized()
	
	velocity = direction * speed
	var center_pos = Vector2(500, 300)
	
	if is_inside_tree():
		snap_position.rpc(center_pos)
	else:
		global_position = center_pos
		sync_position = global_position


@rpc("authority", "call_local", "reliable")
func snap_position(pos: Vector2):
	global_position = pos
	sync_position = global_position


func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		var collision = move_and_collide(velocity * delta)
		
		if collision:
			direction = direction.bounce(collision.get_normal())
			speed += 20.0
			velocity = direction * speed
		
		sync_position = global_position
	else:
		global_position = global_position.lerp(sync_position, 20 * delta)
