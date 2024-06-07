extends CharacterBody2D
class_name Player

@export var speed: float = 90.0
@export var jump_height: float = 65.0
@export var time_jump_apex: float = 0.4

@onready var mini_game = $MiniGame
@onready var animation_player = $animation  # Assurez-vous que ce chemin est correct pour votre AnimationPlayer
@onready var footstep_sound = $FootstepSound  # Assurez-vous que ce chemin est correct pour votre AudioStreamPlayer

var gravity: float
var jump_force: float
var on_ground: bool = false
var can_double_jump: bool = false
var is_double_jumping: bool = false
var current_lamp = null

var total_lampes: int = 0
var lampes_allumees: int = 0

var can_move: bool = false  # Variable pour contrôler le mouvement du joueur, désactivée par défaut

signal all_lamps_on

func _ready():
	gravity = (2 * jump_height) / pow(time_jump_apex, 2)
	jump_force = gravity * time_jump_apex

	$Label.visible = false
	
	mini_game.connect("mini_game_success", Callable(self, "_on_mini_game_success"))
	mini_game.connect("mini_game_failed", Callable(self, "_on_mini_game_failed"))  # Connecter le signal d'échec
	print("Player ready")
	print("MiniGame visibility: ", mini_game.visible)

	# Connecter toutes les lampes
	init_lampes()

func init_lampes():
	var lamps = get_tree().get_nodes_in_group("lamps")
	total_lampes = lamps.size()
	for lamp in lamps:
		lamp.connect("lampe_allumee", Callable(self, "_on_lampe_allumee"))
	update_label()

func _on_lampe_allumee():
	lampes_allumees += 1
	update_label()
	$Label.visible = true
	get_tree().create_timer(2.0).connect("timeout", Callable(self, "_on_label_timer_timeout"))
	if lampes_allumees == total_lampes:
		print("All lamps are on")
		emit_signal("all_lamps_on")

func update_label():
	$Label.text = "%d/%d" % [lampes_allumees, total_lampes]

func _on_label_timer_timeout():
	$Label.visible = false

func _physics_process(delta: float):
	velocity.y += gravity * delta

	if can_move:
		var was_moving = velocity.x != 0

		if Input.is_action_pressed("ui_left"):
			move_left()
		elif Input.is_action_pressed("ui_right"):
			move_right()
		else:
			velocity.x = 0

		if Input.is_action_just_pressed("ui_up"):
			jump()

		if Input.is_action_just_pressed("move_down") and on_ground:
			move_down()

		var is_moving = velocity.x != 0

		if on_ground:
			if is_moving and !was_moving:
				if not footstep_sound.playing:
					footstep_sound.play()
			elif !is_moving and was_moving:
				if footstep_sound.playing:
					footstep_sound.stop()
		else:
			if footstep_sound.playing:
				footstep_sound.stop()
	else:
		velocity.x = 0

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
	$animation.flip_h = false  # Assurez-vous que le sprite est orienté correctement vers la droite

func move_left():
	velocity.x = -speed
	$animation.flip_h = true  # Retourner le sprite vers la gauche

func jump():
	if on_ground:
		velocity.y = -jump_force
		on_ground = false
		can_double_jump = true
	else:
		if can_double_jump:
			velocity.y = -jump_force
			can_double_jump = false
			is_double_jumping = true

func _on_Area2D_body_exited(body: Node):
	set_collision_layer_value(2, true)

func move_down():
	position.y += 1
	print("Moved down")

func start_mini_game(lamp):
	current_lamp = lamp
	can_move = false  # Désactiver le mouvement du joueur
	mini_game.show()
	mini_game.start_mini_game(lamp)
	print("Mini-game position: %s" % str(mini_game.position))
	print("MiniGame visibility après show: ", mini_game.visible)
	print("MiniGame Z-Index: ", mini_game.z_index)

func _on_mini_game_success():
	can_move = true  # Réactiver le mouvement du joueur
	if current_lamp != null:
		current_lamp.allumer_lampe()
		current_lamp = null

func _on_mini_game_failed():
	can_move = true  # Réactiver le mouvement du joueur en cas d'échec
