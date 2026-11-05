# life.gd
extends CharacterBody2D

signal picked_up(type)

const SPEED := 40.0
const GRAVITY := 900.0
var _direction := 1.0


func _ready():
	$AnimatedSprite2D.play("default")
	set_physics_process(false)


func emerge():
	$CollisionShape2D.disabled = true
	$PickupArea.monitoring = false
	z_index = -1
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y - 16, 0.5)
	await tween.finished
	z_index = 0
	$CollisionShape2D.disabled = false
	$PickupArea.monitoring = true
	set_physics_process(true)


func _physics_process(delta):
	velocity.x = _direction * SPEED
	velocity.y += GRAVITY * delta
	move_and_slide()
	if is_on_wall():
		_direction *= -1.0


func _on_pickup_area_body_entered(body):
	if body.is_in_group("player"):
		picked_up.emit("life")
		queue_free()
