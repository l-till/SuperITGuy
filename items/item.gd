extends Area2D


# signals
signal picked_up


# variables
var textures = {
	"cookie": "res://items/item_assets/cookie.png",
	"floppy": "res://items/item_assets/Spinning_Floppy_Disk.png"
}


# initializes the items
func init(type, _position):
	$Sprite2D.texture = load(textures[type])
	position = _position


# detects the collision with the player
func _on_body_entered(body):
	picked_up.emit()
	queue_free()
