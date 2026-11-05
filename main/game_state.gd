extends Node
var num_levels = 1
var current_level = 0
var game_scene = "res://main/main.tscn"
var title_screen = "res://ui/title.tscn"
var control_screen = "res://ui/controls.tscn"
func restart():
	current_level = 0
	get_tree().change_scene_to_file(title_screen)
func next_level():
	current_level += 1
	if current_level <= num_levels:
		get_tree().change_scene_to_file(game_scene)
	else:
		restart()
func show_controls():
	get_tree().change_scene_to_file(control_screen)
