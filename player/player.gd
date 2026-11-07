# player.gd
extends CharacterBody2D

# signals
signal life_changed
signal died

# constants
const BIG_SCALE = Vector2(1.25, 1.25)
@onready var sprite_base_pos = $Spite2D.position
@onready var shape_base_pos = $CollisionShape2D.position

# export variables
@export var gravity = 750
@export var run_speed = 150
@export var jump_speed = -300
@export var max_jumps = 1
@export var double_jump_factor = 1.5


# enums and variables
enum {IDLE, RUN, JUMP, HURT, DEAD, CLIMB}
var state = IDLE
var life = 3: set = set_life
var jump_count = 0
var is_dead = false
var invincible = false


# sets the players life
func set_life(value):
	life = value
	life_changed.emit(life)
	if life <= 0:
		change_state(DEAD)


# ready function
func _ready():
	change_state(IDLE)


# handles character state
func change_state(new_state):
	state = new_state
	match state:
		IDLE:
			$AnimationPlayer.play("idle")
		RUN:
			$AnimationPlayer.play("run")
		HURT:
			$AnimationPlayer.play("hurt")
			velocity.y = -200
			velocity.x = -100 * sign(velocity.x)
			life -= 1
			await get_tree().create_timer(0.5).timeout
			change_state(IDLE)
			if life <= 0:
				change_state(DEAD)
		JUMP:
			$AnimationPlayer.play("jump_up")
			jump_count = 1
		DEAD:
			died.emit()
			hide()


#
func get_input():
	# no movement if hurt
	if state == DEAD:
		return
	
	# gets input
	var right = Input.is_action_pressed("right")
	var left = Input.is_action_pressed("left")
	var jump = Input.is_action_just_pressed("jump")
	var up = Input.is_action_pressed("up")
	var down = Input.is_action_pressed("down")
	
	
	# movement occurs in all states
	velocity.x = 0
	if right:
		velocity.x += run_speed
		$Sprite2D.flip_h = false
	if left:
		velocity.x -= run_speed
		$Sprite2D.flip_h = true
	
	# double jump
	if jump and state == JUMP and jump_count < max_jumps and jump_count > 0:
		$JumpSound.play()
		$AnimationPlayer.play("jump_up")
		velocity.y = jump_speed / double_jump_factor
		jump_count += 1
	
	# only allow jumping when on the ground
	if jump and is_on_floor():
		change_state(JUMP)
		$JumpSound.play()
		velocity.y = jump_speed
	
	# IDLE transitions to RUN when moving
	if state == IDLE and velocity.x != 0:
		change_state(RUN)
	
	# RUN transitions to IDLE when standing still
	if state == RUN and velocity.x == 0:
		change_state(IDLE)
	
	# transition to JUMP when in the air
	if state in [IDLE, RUN] and !is_on_floor():
		change_state(JUMP)

# checks for interaction with blocks
func _check_block_hits() -> void:
	for i in get_slide_collision_count():
		var c := get_slide_collision(i)
		var collider := c.get_collider()
		# Normal pointing down means we hit something with our head
		if c.get_normal().is_equal_approx(Vector2.DOWN) and collider.has_method("hit"):
			collider.hit(self)
			break

#
func _physics_process(delta):
	velocity.y += gravity * delta
	get_input()
	#
	move_and_slide()
	#
	_check_block_hits()
	#
	if state == DEAD:
		return
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().is_in_group("danger"):
			hurt()
		if collision.get_collider().is_in_group("enemies"):
			if position.y < collision.get_collider().position.y:
				collision.get_collider().take_damage()
				velocity.y = -200
			else:
				hurt()
	#
	if state == JUMP and is_on_floor():
		change_state(IDLE)
		$Dust.emitting = true
		jump_count = 0
	if state == JUMP and velocity.y > 0:
		$AnimationPlayer.play("jump_down")

# Grow with cookie
func grow():
	if GameState.is_big:
		return
	GameState.is_big = true
	_apply_size()

# Shrink if hurt
func shrink():
	GameState.is_big = false
	_apply_size()
	_start_invincibility()

# resets the game
func reset(pos):
	position = pos
	is_dead = false
	_apply_size()

# Brief invicibility after getting hurt
func _start_invincibility():
	invincible = true
	var tween = create_tween().set_loops(10)
	tween.tween_property($Sprite2D, "modulate:a", 0.3, 0.1)
	tween.tween_property($Sprite2D, "modulate:a", 1.0, 0.1)
	await tween.finished
	$Sprite2D.modulate.a = 1.0
	invincible = false

# sets size
func _apply_size(animate := true):
	var s = BIG_SCALE if GameState.is_big else Vector2.ONE
	if animate:
		var tween = create_tween().set_parallel(true)
		tween.tween_property($Sprite2D, "scale", s, 0.15)
		tween.tween_property($Sprite2D, "position", sprite_base_pos * s, 0.15)
		tween.tween_property($CollisionShape2D, "scale", s, 0.15)
		tween.tween_property($CollisionShape2D, "position", shape_base_pos * s, 0.15)
	else:
		$Sprite2D.scale = s
		$Sprite2D.position = sprite_base_pos * s
		$CollisionShape2D.scale = s
		$CollisionShape2D.position = shape_base_pos * s

# player hurt
func hurt():
	if invincible or is_dead:
		return
	if GameState.is_big:
		shrink()
	else:
		die()

func die():
	if is_dead:
		return
	is_dead = true
	set_physics_process(false)
	$CollisionShape2D.set_deferred("disabled", true)
	await get_tree().create_timer(1.0).timeout
	died.emit()
