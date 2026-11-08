extends Control


#
func _input(event):
	if event.is_action_pressed("jump"):
		GameState.next_level()
#	elif event.is_action_pressed("flip_gravity"):
#		GameState.show_controls()
