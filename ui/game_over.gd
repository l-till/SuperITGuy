# game_over.gd
extends Control


func _ready():
	await get_tree().create_timer(5.0).timeout
	GameState.restart()
