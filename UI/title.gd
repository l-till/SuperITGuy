extends Control


#
func _input(event):
	if event.is_action_pressed("jump"):
		GameState.next_level()
