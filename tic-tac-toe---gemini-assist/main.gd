extends Node2D

@onready var host_button: Button = $CanvasLayer/CenterContainer/VBoxContainer/HBoxContainer/HostButton
@onready var join_button: Button = $CanvasLayer/CenterContainer/VBoxContainer/HBoxContainer/JoinButton
@onready var status_label: Label = $CanvasLayer/CenterContainer/VBoxContainer/StatusLabel
@onready var board_grid: GridContainer = $CanvasLayer/CenterContainer/VBoxContainer/BoardGrid
@onready var restart_button: Button = $CanvasLayer/CenterContainer/VBoxContainer/RestartButton


const winning_combinations = [
	[0, 1, 2], [3, 4, 5], [6, 7, 8],
	[0, 3, 6], [1, 4, 7], [2, 5, 8],
	[0, 4, 8], [2, 4, 6]
]

var board_state = [0, 0, 0, 0, 0, 0, 0, 0, 0]
var next_first_player = 1
var current_turn_id: int = 0
var players: Dictionary = {}


func _ready() -> void:
	host_button.pressed.connect(_on_host)
	join_button.pressed.connect(_on_join)
	restart_button.pressed.connect(reset_game_state)
	
	for i in range(9):
		var btn = board_grid.get_child(i) as Button
		btn.pressed.connect(_on_cell_clicked.bind(i))


func _on_host():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(8910, 1)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connect)
	players[multiplayer.get_unique_id()] = 1
	hide_network_ui()
	status_label.text = "Waiting player 2..."


func _on_join():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client("127.0.0.1", 8910)
	multiplayer.multiplayer_peer = peer
	hide_network_ui()
	status_label.text = "Connected. Waiting for server..."


func reset_game_state():
	if not multiplayer.is_server(): return
	
	for i in range(9):
		board_state[i] = 0
	
	current_turn_id = next_first_player
	for player_id in players:
			if player_id != next_first_player:
				next_first_player = player_id
				break
	
	sync_game_state.rpc(board_state, current_turn_id)
	restart_button.hide()


func _on_cell_clicked(cell_index: int):
	request_move.rpc_id(1, cell_index)


func hide_network_ui():
	host_button.hide()
	join_button.hide()


func _on_peer_connect(peer_id: int):
	players[peer_id] = 2
	
	if multiplayer.is_server():
		reset_game_state()


@rpc("any_peer", "call_local", "reliable")
func request_move(cell_index: int):
	if not multiplayer.is_server(): return
	
	var sender_id = multiplayer.get_remote_sender_id()
	
	if sender_id != current_turn_id: return
	
	if board_state[cell_index] != 0: return
	
	board_state[cell_index] = players[sender_id]
	
	var match_status = check_match_status(board_state)
	
	if match_status != 0:
		end_game.rpc(board_state, match_status)
	else:
		for player_id in players:
			if player_id != current_turn_id:
				current_turn_id = player_id
				break
		sync_game_state.rpc(board_state, current_turn_id)


@rpc("authority", "call_local", "reliable")
func sync_game_state(new_board_state: Array, new_turn_id: int):
	board_state = new_board_state
	current_turn_id = new_turn_id
	
	redraw_board()
	
	var my_id = multiplayer.get_unique_id()
	
	if my_id == new_turn_id:
		status_label.text = "YOUR TURN!"
		set_grid_buttons(true)
	else:
		status_label.text = "Opponent's turn..."
		for btn in board_grid.get_children():
			set_grid_buttons(false)


func check_match_status(board: Array):
	for combination in winning_combinations:
		var a = combination[0]
		var b = combination[1]
		var c = combination[2]
		
		if board[a] != 0 && board[a] == board[b] && board[a] == board[c]:
			return board[a]
	
	if not 0 in board:
		return -1
	
	return 0


func redraw_board():
	for i in range(9):
		var btn = board_grid.get_child(i) as Button
		if board_state[i] == 1:
			btn.text = "X"
		elif board_state[i] == 2:
			btn.text = "O"
		else:
			btn.text = ""


func set_grid_buttons(state: bool):
	for btn in board_grid.get_children():
			btn.disabled = !state


@rpc("authority", "call_local", "reliable")
func end_game(final_board: Array, result: int):
	board_state = final_board
	redraw_board()
	set_grid_buttons(false)
	
	var my_player_number = 1 if multiplayer.is_server() else 2
	
	if result == -1:
		status_label.text = "DRAW!"
	elif result == my_player_number:
		status_label.text = "YOU WIN!"
	else:
		status_label.text = "YOU LOSE!"
	
	if multiplayer.is_server():
		restart_button.show()
