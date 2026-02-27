extends Control

@onready var player_name: LineEdit = $PlayerName
@onready var player_list: ItemList = $PlayerList


func _ready() -> void:
	NetworkHandler.player_list_changed.connect(_on_player_list_changed)


func update_name():
	var new_name = player_name.text
	NetworkHandler.player_name = new_name


func _on_host_button_pressed() -> void:
	update_name()
	NetworkHandler.host()
	hide_ui()


func _on_join_button_pressed() -> void:
	update_name()
	NetworkHandler.join()
	hide_ui()


func _on_player_list_changed():
	player_list.clear()
	for player_id in NetworkHandler.players:
		player_list.add_item(NetworkHandler.players[player_id])


func hide_ui():
	$HostButton.hide()
	$JoinButton.hide()
	if multiplayer.is_server():
		$StartButton.show()


func _on_start_button_pressed() -> void:
	NetworkHandler.start_game()
