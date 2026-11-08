# win.gd
extends Control

var can_skip = false


func _ready():
	await get_tree().create_timer(1.0).timeout
	can_skip = true


func _input(event):
	if can_skip and event.is_pressed() and not event.is_echo():
		GameState.restart()
