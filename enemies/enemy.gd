# enemy.gd
extends CharacterBody2D


#
@export var speed = 50
@export var gravity = 900


#
var facing = -1
var dead = false


#
func _physics_process(delta):
	velocity.y += gravity * delta
	velocity.x = facing * speed
	$AnimatedSprite2D.flip_h = velocity.x > 0
	move_and_slide()
	if is_on_wall():
		facing = sign(get_wall_normal().x)
	if position.y > 10000:
		queue_free()


#
func take_damage():
	if dead:
		return
	dead = true
	$AnimatedSprite2D.play("death")
	$EnemyHitSound.play()
	$CollisionShape2D.set_deferred("disabled", true)
	set_physics_process(false)


#
func _on_animated_sprite_2d_animation_finished(anim_name):
	if $AnimatedSprite2D.animation == "death":
		queue_free()
