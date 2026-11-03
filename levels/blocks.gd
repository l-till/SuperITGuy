# blocks.gd
class_name Block
extends StaticBody2D

@export var item_scene: PackedScene
@export var hits_allowed := 1   # set higher for multi-coin blocks

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
	var item := item_scene.instantiate()
	item.global_position = global_position
	get_parent().add_child.call_deferred(item)
