# level_base.gd
extends Node2D

#
signal score_changed

#
var score = 0: set = set_score
var block_scene = load("res://levels/blocks.tscn")
var floppy_scene = load("res://items/loppy.tscn")
var item_scenes = {
	"floppy": load("res://items/block_floppy.tscn"),
	"cookie": load("res://items/cookie.tscn"),
	"life": load("res://items/life.tscn")
	}
@onready var camera = $Player/Camera2D
@onready var bounds = $CameraBounds

#
func _ready():
	$Items.hide()
	$Player.reset($SpawnPoint.position)
	spawn_items()
#	spawn_dangers()
	var rt = $Player/RemoteTransform2D

#
func spawn_items():
	var item_cells = $Items.get_used_cells()
	for cell in item_cells:
		var data = $Items.get_cell_tile_data(cell)
		var type = data.get_custom_data("type")
		if type == "block":
			var block = block_scene.instantiate()
			add_child(block)
			block.position = $Items.map_to_local(cell)
			var contents = data.get_custom_data("contents")
			if contents == "":
				contents = "floppy"
			block.item_scene = item_scenes.get(contents)
		elif type == "floppy":
			var floppy = floppy_scene.instantiate()
			add_child(floppy)
			floppy.position = $Items.map_to_local(cell)
			floppy.picked_up.connect(_on_item_picked_up)

# spawn hazards
#func spawn_dangers():
#	var danger_cells = $Danger.get_used_cells(0)
#	for cell in danger_cells:
#		var data = $Danger.get_cell_tile_data(0, cell)
#		var type = data.get_custom_data("type")
#		if type == "glaser":
#			var glaser = glaser_scene.instantiate()
#			add_child(glaser)
#			glaser.position = $Danger.map_to_local(cell)
#		elif type == "rlaser":
#			var rlaser = rlaser_scene.instantiate()
#			add_child(rlaser)
#			rlaser.position = $Danger.map_to_local(cell)

#
func set_score(value):
	score = value
	score_changed.emit(score)

#
func _on_item_picked_up(type):
	match type:
		"floppy":
			score += 1
		"cookie":
			$Player.grow()
		"life":
			GameState.lives += 1

#
#func _on_server_entered(body):
#	$Door/AnimationPlayer.play("door_open")
#	await $Door/AnimationPlayer.animation_finished
#	GameState.next_level()

#
func _on_player_died():
	GameState.lose_life()

func _on_kill_zone_body_entered(body):
	if body.is_in_group("player"):
		body.die()
