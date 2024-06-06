extends CharacterBody2D
class_name Player

@export var audio_jump: AudioStream = preload("res://sounds/jump.wav")

@export var speed: float = 90.0
@export var jump_height: float = 65.0
@export var time_jump_apex: float = 0.4

@onready var mini_game = $MiniGame

var gravity: float
var jump_force: float
var on_ground: bool = false
var can_double_jump: bool = false
var is_double_jumping: bool = false
var current_lamp = null

var total_lampes: int = 0
var lampes_allumees: int = 0
var label_timer: Timer

func _ready():
	# Calculer la gravité et la force de saut au démarrage
	gravity = (2 * jump_height) / pow(time_jump_apex, 2)
	jump_force = gravity * time_jump_apex

	# Initialiser le label et le timer
	$Label.visible = false
	label_timer = Timer.new()
	label_timer.wait_time = 2.0  # Durée d'affichage en secondes
	label_timer.one_shot = true
	label_timer.connect("timeout", Callable(self, "_on_label_timer_timeout"))
	add_child(label_timer)
	
	# Cacher le mini-jeu au démarrage
	mini_game.hide()
	mini_game.connect("mini_game_success", Callable(self, "_on_mini_game_success"))
	mini_game.z_index = 100  # S'assurer que le mini-jeu est rendu au-dessus des autres éléments
	print("Player ready")
	print("MiniGame visibility: ", mini_game.visible)

func init_lampes(total: int):
	total_lampes = total
	update_label()

func _on_lampe_allumee():
	lampes_allumees += 1
	update_label()
	$Label.visible = true
	label_timer.start()

func update_label():
	$Label.text = "%d/%d" % [lampes_allumees, total_lampes]

func _on_label_timer_timeout():
	$Label.visible = false

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

func start_mini_game(lamp):
	current_lamp = lamp
	mini_game.set_position(position + Vector2(100, 0))  # Positionner le mini-jeu à droite du joueur
	mini_game.show()
	mini_game.z_index = 100  # S'assurer que le mini-jeu est rendu au-dessus des autres éléments
	mini_game.start_mini_game()
	print("Mini-game position: %s" % str(mini_game.global_position))
	print("MiniGame visibility après show: ", mini_game.visible)
	print("MiniGame Z-Index: ", mini_game.z_index)

func _on_mini_game_success():
	if current_lamp != null:
		current_lamp.allumer_lampe()
		current_lamp = null
