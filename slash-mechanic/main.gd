extends Node2D

@export var player_scene: PackedScene


func _ready() -> void:
	$MultiplayerSpawner.spawn_function = _custom_spawn


func _on_join_button_pressed() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_client("127.0.0.1", 8910)
	multiplayer.multiplayer_peer = peer
	$CanvasLayer.hide()


func _on_host_button_pressed() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(8910)
	multiplayer.multiplayer_peer = peer
	$CanvasLayer.hide()
	$MultiplayerSpawner.spawn(multiplayer.get_unique_id())
	multiplayer.peer_connected.connect(func(id): $MultiplayerSpawner.spawn(id))


func _custom_spawn(data) -> Node:
	var player = player_scene.instantiate()
	player.name = str(data)
	player.position = Vector2(randi_range(50, 550), randi_range(50, 550))
	return player
