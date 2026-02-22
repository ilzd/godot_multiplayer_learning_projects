extends Node2D

var peer: ENetMultiplayerPeer
var player_scene = preload("res://player.tscn")


func _ready() -> void:
	multiplayer.peer_disconnected.connect(_remove_player)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		print(multiplayer.get_unique_id())

func _on_host_button_pressed() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_server(8910)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	_add_player(multiplayer.get_unique_id())
	$CanvasLayer/DisconnectButton.show()
	$CanvasLayer/HostButton.hide()
	$CanvasLayer/JoinButton.hide()


func _on_join_button_pressed() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_client("127.0.0.1", 8910)
	multiplayer.multiplayer_peer = peer
	$CanvasLayer/DisconnectButton.show()
	$CanvasLayer/HostButton.hide()
	$CanvasLayer/JoinButton.hide()


func _on_disconnect_button_pressed() -> void:
	peer.close()
	multiplayer.multiplayer_peer = null
	
	for child in $PlayerList.get_children():
		child.queue_free()
	
	$CanvasLayer/DisconnectButton.hide()
	$CanvasLayer/HostButton.show()
	$CanvasLayer/JoinButton.show()


func _remove_player(id):
	var player_node = $PlayerList.get_node_or_null(str(id))
	
	if player_node != null:
		player_node.queue_free()


func _add_player(id):
	var new_player = player_scene.instantiate()
	new_player.name = str(id)
	$PlayerList.add_child(new_player)
