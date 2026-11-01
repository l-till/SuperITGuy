extends Node2D


#
signal score_changed


#
var item_scene = load("res://Items/item.tscn")
var door_scene = load("res://Items/door.tscn")
var score = 0: set = set_score
@onready var camera = $Player/Camera2D
@onready var bounds = $CameraBounds



#
func _ready():
	$Items.hide()
	$Player.reset($SpawnPoint.position)
	spawn_items()
	create_ladders()
	camera.limit_left = bounds.position.x
	camera.limit_top = bounds.position.y
	camera.limit_right = bounds.position.x + bounds.size.x
	camera.limit_bottom = bounds.position.y + bounds.size.y


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
		else:
			var item = item_scene.instantiate()
			add_child(item)
			item.init(type, $Items.map_to_local(cell))
			item.picked_up.connect(self._on_item_picked_up)


# ladders
func create_ladders():
	var cells = $World.get_used_cells(0)
	for cell in cells:
		var data = $World.get_cell_tile_data(0, cell)
		if data.get_custom_data("special") == "ladder":
			var c = CollisionShape2D.new()
			$Ladders.add_child(c)
			c.position = $World.map_to_local(cell)
			var s = RectangleShape2D.new()
			s.size = Vector2(8, 16)
			c.shape = s


#
func _on_item_picked_up():
	$ItemSound.play()
	score += 1


#
func set_score(value):
	score = value
	score_changed.emit(score)


#
func _on_door_entered(body):
	GameState.next_level()


#
func _on_player_died():
	GameState.restart()

# player on ladder
func _on_ladders_body_entered(body):
	body.is_on_ladder = true
func _on_ladders_body_exited(body):
	body.is_on_ladder = false
