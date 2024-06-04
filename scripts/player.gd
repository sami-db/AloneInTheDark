extends CharacterBody2D

@export var audio_jump: AudioStream = preload("res://sounds/jump.wav")

@export var speed: float = 90.0
@export var jump_height: float = 65.0
@export var time_jump_apex: float = 0.4
var gravity: float
var jump_force: float

var on_ground: bool = false
var can_double_jump: bool = false
var is_double_jumping: bool = false

func _ready():
	# Calculer la gravité et la force de saut au démarrage
	gravity = (2 * jump_height) / pow(time_jump_apex, 2)
	jump_force = gravity * time_jump_apex

func _physics_process(delta: float):
	velocity.y += gravity * delta
	
	if Input.is_action_pressed("ui_left"):
		move_left()
	elif Input.is_action_pressed("ui_right"):
		move_right()
	else:
		velocity.x = 0
	
	if Input.is_action_just_pressed("ui_up"):
		jump()

	# Utiliser la méthode appropriée pour déplacer le personnage
	move_and_slide()

	if is_on_floor():
		on_ground = true
		can_double_jump = false
		is_double_jumping = false
		
		if velocity.x == 0:
			$animation.play("idle")
		else:
			$animation.play("run")
	else:
		on_ground = false
		if velocity.y < 0:
			if is_double_jumping:
				$animation.play("doubleJump")
			else:
				$animation.play("jump")
		else:
			$animation.play("fall")    

func move_right():
	velocity.x = speed
	$animation.flip_h = false

func move_left():
	velocity.x = -speed
	$animation.flip_h = true

func jump():
	if on_ground:
		if $check_platform.is_colliding() and Input.is_action_pressed("ui_down"):
			set_collision_layer_value(2, false)
		else:
			velocity.y = -jump_force
			on_ground = false
			$audio.stream = audio_jump
			$audio.play()
			can_double_jump = true
	else:
		if can_double_jump:
			velocity.y = -jump_force
			can_double_jump = false
			is_double_jumping = true

func _on_Area2D_body_exited(body: Node):
	set_collision_layer_value(2, true)
