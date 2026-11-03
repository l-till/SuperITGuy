# level_base.gd
extends Node2D


#
signal score_changed


#
var glaser_scene = load("res://Items/green_laser.tscn")
var rlaser_scene = load("res://Items/red_laser.tscn")
var door_scene = load("res://Items/door.tscn")
var score = 0: set = set_score
@onready var camera = $Player/Camera2D
@onready var bounds = $CameraBounds



#
func _ready():
	$Items.hide()
	$Player.reset($SpawnPoint.position)
	spawn_items()
	spawn_dangers()
	var rt = $Player/RemoteTransform2D


#
func spawn_items():
	var item_cells = $Items.get_used_cells(0)
	for cell in item_cells:
		var data = $Items.get_cell_tile_data(0, cell)
		var type = data.get_custom_data("type")
		if type == "door":
			var door = door_scene.instantiate()
			add_child(door)
			door.position = $Items.map_to_local(cell)
			door.body_entered.connect(_on_door_entered)


# spawn hazards
func spawn_dangers():
	var danger_cells = $Danger.get_used_cells(0)
	for cell in danger_cells:
		var data = $Danger.get_cell_tile_data(0, cell)
		var type = data.get_custom_data("type")
		if type == "glaser":
			var glaser = glaser_scene.instantiate()
			add_child(glaser)
			glaser.position = $Danger.map_to_local(cell)
		elif type == "rlaser":
			var rlaser = rlaser_scene.instantiate()
			add_child(rlaser)
			rlaser.position = $Danger.map_to_local(cell)


# ladders
#func create_ladders():
#	var cells = $World.get_used_cells(0)
#	for cell in cells:
#		var data = $World.get_cell_tile_data(0, cell)
#		if data.get_custom_data("special") == "ladder":
#			var c = CollisionShape2D.new()
#			$Ladders.add_child(c)
#			c.position = $World.map_to_local(cell)
#			var s = RectangleShape2D.new()
#			s.size = Vector2(8, 16)
#			c.shape = s


#
func set_score(value):
	score = value
	score_changed.emit(score)


#
func _on_door_entered(body):
	$Door/AnimationPlayer.play("door_open")
	await $Door/AnimationPlayer.animation_finished
	GameState.next_level()


#
func _on_player_died():
	get_tree().reload_current_scene()

# player on ladder
func _on_ladders_body_entered(body):
	body.is_on_ladder = true
func _on_ladders_body_exited(body):
	body.is_on_ladder = false
