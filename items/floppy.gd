# floppy.gd
extends Area2D

signal picked_up(type)

@export var type := "floppy"


func _ready():
	$AnimatedSprite2D.play("default")


func emerge():
	monitoring = false
	z_index = -1
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y - 16, 0.4)
	await tween.finished
	z_index = 0
	monitoring = true


func _on_body_entered(body):
	if body.is_in_group("player"):
		picked_up.emit(type)
		queue_free()
