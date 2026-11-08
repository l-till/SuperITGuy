# intro.gd
extends Control

#
var can_continue = false

#
func _ready():
	#$CenterContainer/VBoxContainer/WorldLabel.text = "WORLD 1-" + str(GameState.current_level)
	#$CenterContainer/VBoxContainer/LivesLabel.text = "X " + str(GameState.lives)
	await get_tree().create_timer(0.5).timeout
	can_continue = true

#
func _input(event):
	if can_continue and event.is_pressed() and not event.is_echo():
		can_continue = false
		get_tree().change_scene_to_file(GameState.game_scene)
