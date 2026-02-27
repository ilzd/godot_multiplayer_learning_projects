extends CharacterBody2D

@export var slash_scene: PackedScene

var pierce_attribute: int = 10


func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())


func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		velocity = direction * 300.0
		move_and_slide()
		
		if Input.is_action_just_pressed("slash"):
			if not has_node("SlashPivot"):
				perform_slash()


func perform_slash():
	var aim_rotation = get_angle_to(get_global_mouse_position())
	
	spawn_slash(aim_rotation, true)
	rpc("play_slash_visual", aim_rotation)


func spawn_slash(aim_rotation: float, has_authority: bool):
	var slash = slash_scene.instantiate()
	slash.name = "SlashPivot"
	slash.rotation = aim_rotation
	slash.is_authority = has_authority
	slash.attacker_id = name.to_int()
	slash.pierce_limit = pierce_attribute
	
	add_child(slash)


@rpc("any_peer", "call_remote", "reliable")

func play_slash_visual(aim_rotation: float):
	spawn_slash(aim_rotation, false)
