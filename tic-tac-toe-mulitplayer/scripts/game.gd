extends Node2D

var area_scene = preload("res://scenes/play_area.tscn")

var current_player = 1

var game_state = [
	[0, 0, 0],
	[0, 0, 0],
	[0, 0, 0]
]


func _enter_tree() -> void:
	NetworkHandler.match_started.connect(_on_match_started)


func _on_match_started():
	if multiplayer.is_server():
		start.rpc()


func _ready() -> void:
	NetworkHandler.player_loaded.rpc_id(1)


@rpc("authority", "call_local", "reliable")
func start():
	prepare()
	set_player(1)
	game_state = [
		[0, 0, 0],
		[0, 0, 0],
		[0, 0, 0]
	]
	$UI.hide()
	$RestartButton.hide()


func prepare():
	for child in $AreaList.get_children():
		child.queue_free()
	
	var area_size = get_viewport_rect().size
	var step_x = area_size.x / 3
	var step_y = area_size.y / 3
	
	for i in range(3):
		for j in range(3):
			var new_area = area_scene.instantiate() as PlayArea
			new_area.position = Vector2(i * step_x + 40, j * step_y + 40)
			new_area.name = "PlayArea_" + str(i) + "-" + str(j)
			new_area.set_coords(i, j)
			new_area.area_played.connect(_on_area_played)
			$AreaList.add_child(new_area)


func _on_area_played(x: int, y: int):
	play_position.rpc(x, y)


@rpc("any_peer", "call_local", "reliable")
func play_position(x: int, y: int):
	var area: PlayArea
	
	for child in $AreaList.get_children():
		if child.x == x && child.y == y:
			area = child
			break
	
	if area != null:
		area.set_symbol("X" if current_player == 1 else "O")
	game_state[x][y] = current_player
	
	set_player(1 if current_player == 2 else 2)
	if(multiplayer.is_server()):
		check_game_state()


func toggle_areas(state: bool):
	var areas = $AreaList.get_children() as Array[Area2D]
	for area in areas:
		area.input_pickable = state
		area.get_node("ColorRect").visible = state


func set_player(id: int):
	current_player = id
	
	if multiplayer.is_server() and id == 1:
		toggle_areas(true)
	elif not multiplayer.is_server() and id == 2:
		toggle_areas(true)
	else:
		toggle_areas(false)


@rpc("authority", "call_local", "reliable")
func set_winner(winner_id: int):
	$UI/WinnerLabel.text = "Player " + str(winner_id) + " wins!"
	$UI.show()
	if(multiplayer.is_server()):
		$RestartButton.show()


func check_game_state():
	if not multiplayer.is_server(): return
	
	for i in range(3):
		if game_state[i][0] != 0 && game_state[i][0] == game_state[i][1] && game_state[i][0] == game_state[i][2]:
			set_winner.rpc(game_state[i][0])
		elif game_state[0][i] != 0 &&game_state[0][i] == game_state[1][i] && game_state[0][i] == game_state[2][i]:
			set_winner.rpc(game_state[0][i])


func _on_restart_button_pressed() -> void:
	if multiplayer.is_server():
		start.rpc()
