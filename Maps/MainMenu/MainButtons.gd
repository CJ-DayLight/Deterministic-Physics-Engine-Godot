extends VBoxContainer







func _on_HostGame_pressed():
	MultiPlayerFunctions.HostGame()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().change_scene("res://Maps/PlayGround/PlayGround.tscn")


func _on_JoinGame_pressed():
	MultiPlayerFunctions.JoinGame()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().change_scene("res://Maps/PlayGround/PlayGround.tscn")
