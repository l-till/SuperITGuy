# game_state.gd
extends Node

#
signal lives_changed(value)

# CONSTANTS
const START_LIVES = 3

# Variables
var num_levels = 1
var current_level = 0
var game_scene = "res://main/main.tscn"
var title_screen = "res://ui/title.tscn"
var control_screen = "res://ui/controls.tscn"
var intro_screen = "res://ui/intro.tscn"
var game_over_screen = "res://ui/game_over.tscn"
var win_screen = "res://ui/win.tscn"
var lives = START_LIVES: set = set_lives
var is_big = false

#
func set_lives(value):
	lives = value
	lives_changed.emit(lives)

#
func lose_life():
	lives -= 1
	is_big = false
	if lives <= 0:
		get_tree().change_scene_to_file.call_deferred(game_over_screen)
	else:
		get_tree().reload_current_scene.call_deferred()

#
func restart():
	current_level = 0
	lives = START_LIVES
	is_big = false
	get_tree().change_scene_to_file(title_screen)

#
func next_level():
	current_level += 1
	if current_level <= num_levels:
		get_tree().change_scene_to_file.call_deferred(intro_screen)
	else:
		get_tree().change_scene_to_file.call_deferred(win_screen)

#
func show_controls():
	get_tree().change_scene_to_file(control_screen)
