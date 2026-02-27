extends Node

signal connected_to_server
signal player_list_changed
signal match_started

const ADDRESS: String = "127.0.0.1"
const PORT: int = 4910
const GAME_SCENE_PATH: String = "res://scenes/game.tscn"

var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()

var players: Dictionary = {}

var player_name = "Player"

var players_loaded: int = 0


func _enter_tree() -> void:
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.peer_connected.connect(_on_peer_connected)


func host():
	print("Creating game")
	peer.create_server(PORT, 1)
	multiplayer.multiplayer_peer = peer
	_on_peer_connected(multiplayer.get_unique_id())


func join():
	print("Joining game")
	peer.create_client(ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer


func start_game():
	print("Starting Game")
	if players.size() < 2: return
	load_game.rpc()


@rpc("authority", "call_local", "reliable")
func load_game():
	print("Loading game scene")
	get_tree().change_scene_to_file(GAME_SCENE_PATH)


func _on_peer_connected(id: int):
	register_player.rpc_id(id, player_name)


func _on_connected_to_server():
	players[str(multiplayer.get_unique_id())] = player_name
	connected_to_server.emit()


@rpc("any_peer", "call_local", "reliable")
func register_player(new_player_name: String):
	print(new_player_name, " registered.")
	var peer_id = multiplayer.get_remote_sender_id()
	players[str(peer_id)] = new_player_name
	player_list_changed.emit()


@rpc("any_peer", "call_local", "reliable")
func player_loaded():
	players_loaded += 1
	print("Players loaded: ", players_loaded, "/", players.size()) 
	
	if players_loaded == players.size():
		print("All players loaded, starting match...")
		match_started.emit()
