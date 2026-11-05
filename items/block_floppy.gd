# block_floppy.gd
extends Node2D

signal picked_up(type)

#
func _ready():
	$AnimatedSprite2D.play("default")


#
func emerge():
	picked_up.emit("floppy")
	var start_y = position.y
	var tween = create_tween()
	tween.tween_property(self, "position:y", start_y - 56, 0.3) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", start_y - 24, 0.3) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await tween.finished
	queue_free()
