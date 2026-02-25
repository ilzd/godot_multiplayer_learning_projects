extends Control


func _on_host_button_pressed() -> void:
	NetworkHandler.create_server()


func _on_join_button_pressed() -> void:
	NetworkHandler.create_client()
