extends Node

const IP_ADDRESS: String = "127.0.0.1"
const PORT: int = 8910

var peer: ENetMultiplayerPeer

func create_server():
	peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer


func create_client():
	peer = ENetMultiplayerPeer.new()
	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer
