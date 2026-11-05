# blocks.gd
class_name Block
extends StaticBody2D

@export var item_scene: PackedScene
@export var hits_allowed := 1
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var _bouncing := false

func _ready() -> void:
	sprite.play("idle")

func hit(_player: Node) -> void:
	if hits_allowed <= 0 or _bouncing:
		return
	hits_allowed -= 1
	_bounce()
	_spawn_item()
	if hits_allowed == 0:
		sprite.play("empty")

func _bounce() -> void:
	_bouncing = true
	var start_y := sprite.position.y
	var tween := create_tween()
	tween.tween_property(sprite, "position:y", start_y - 8, 0.08) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "position:y", start_y, 0.08) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.finished.connect(func(): _bouncing = false)

func _spawn_item() -> void:
	if item_scene == null:
		return
	var item = item_scene.instantiate()
	item.position = position   # block and item share the level as parent
	item.picked_up.connect(get_parent()._on_item_picked_up)
	get_parent().add_child.call_deferred(item)
	if item.has_method("emerge"):
		item.emerge.call_deferred()
