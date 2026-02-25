extends Node2D

@export var paddle_scene: PackedScene
@export var ball_scene: PackedScene

var peer = ENetMultiplayerPeer.new()
var players_connected = 0

var host_score: int = 0
var client_score: int = 0


func _ready() -> void:
	$PlayerSpawner.spawn_function = _spawn_paddle


func _on_host_button_pressed() -> void:
	peer.create_server(8910)
	multiplayer.multiplayer_peer = peer
	_on_peer_connected(multiplayer.get_unique_id())
	
	multiplayer.peer_connected.connect(_on_peer_connected)
	
	$NetworkUI.hide()


func _on_join_button_pressed() -> void:
	peer.create_client("127.0.0.1", 8910)
	multiplayer.multiplayer_peer = peer
	$NetworkUI.hide()


func _on_peer_connected(id: int):
	var spawn_position = $SpawnPoints/HostSpawn.position if id == 1 else $SpawnPoints/ClientSpawn.position
	var spawn_data = {
		"id": id,
		"position": spawn_position
	}
	$PlayerSpawner.spawn(spawn_data)
	
	players_connected += 1
	if players_connected == 2 and multiplayer.is_server():
		var ball = ball_scene.instantiate()
		ball.name = "GameBall"
		ball.reset_ball()
		add_child(ball)


func _spawn_paddle(data: Dictionary):
	var new_paddle = paddle_scene.instantiate()
	new_paddle.name = str(data["id"])
	new_paddle.position = data["position"]
	return new_paddle


func _on_left_goal_body_entered(body: Node2D) -> void:
	if multiplayer.is_server() and body.name == "GameBall":
		print("client scored")
		client_score += 1
		update_score_ui.rpc(host_score, client_score)
		body.reset_ball()


func _on_right_goal_body_entered(body: Node2D) -> void:
	if multiplayer.is_server() and body.name == "GameBall":
		host_score += 1
		update_score_ui.rpc(host_score, client_score)
		body.reset_ball()


@rpc("authority", "call_local", "reliable")
func update_score_ui(new_host_score: int, new_client_score: int):
	host_score = new_host_score
	client_score = new_client_score
	
	$ScoreUI/HBoxContainer/HostScoreLabel.text = str(host_score)
	$ScoreUI/HBoxContainer/ClientScoreLabel.text = str(client_score)
