extends Node2D

@onready var forward_label = $forward
@onready var backward_label = $backward
@onready var jump_label = $jump
@onready var potentiometer_label = $potentiometer
@onready var black_button = $black_button
@onready var white_button = $white_button
@onready var blue_button = $blue_button
@onready var circle = $circle
@onready var indicator = $indicator

@onready var camera = $Camera2D  # Assurez-vous que ce chemin est correct pour votre Camera2D
@onready var animation_player = $AnimationPlayer  # Assurez-vous que ce chemin est correct pour votre AnimationPlayer
@onready var player = $player  # Assurez-vous que ce chemin est correct pour votre joueur
@onready var spawn_sprite = $SpawnSprite  # Le sprite ou AnimationPlayer pour l'animation de spawn
@onready var point_light = $Node2D/PointLight2D  # Assurez-vous que ce chemin est correct pour votre PointLight2D
@onready var door = $Door  # Référence à la porte (mettre à jour si nécessaire)

var total_lampes: int = 0

func _ready():
	if camera:
		camera.make_current()  # Forcer la caméra de la scène à être la caméra active
		print("Scene camera is now active")

	if player and animation_player and spawn_sprite and point_light:
		print("Player, AnimationPlayer, SpawnSprite, and PointLight2D found")
		disable_player_point_lights()
		player.visible = false  # Masquer le joueur au début
		hide_all_labels()
		point_light.visible = true  # Activer le PointLight2D au début
		start_spawn_animation()
	else:
		print("Erreur : Player, AnimationPlayer, SpawnSprite, ou PointLight2D non trouvé")

	init_lampes()

func hide_all_labels():
	forward_label.visible = false
	backward_label.visible = false
	jump_label.visible = false
	potentiometer_label.visible = false
	black_button.visible = false
	white_button.visible = false
	blue_button.visible = false

func show_all_labels():
	forward_label.visible = true
	backward_label.visible = true
	jump_label.visible = true
	potentiometer_label.visible = true
	black_button.visible = true
	white_button.visible = true
	blue_button.visible = true

func disable_player_point_lights():
	for child in player.get_children():
		if child is PointLight2D:
			child.queue_free()  # Enlever le PointLight2D
			print("PointLight2D removed in player")

func start_spawn_animation():
	if animation_player:
		animation_player.connect("animation_finished", Callable(self, "_on_AnimationPlayer_animation_finished"))
		animation_player.play("SpawnAndZoom")  # Jouer l'animation de zoom

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "SpawnAndZoom":
		spawn_sprite.visible = false  # Masquer le sprite d'animation de spawn
		point_light.visible = false  # Désactiver le PointLight2D
		player.visible = true  # Afficher le joueur une fois l'animation terminée
		player.can_move = true  # Réactiver les contrôles du joueur
		show_all_labels()

func init_lampes():
	# Compter toutes les lampes dans la scène
	var lampes = get_tree().get_nodes_in_group("lamps")
	total_lampes = lampes.size()

	# Connecter le signal de chaque lampe à la fonction _on_lampe_allumee du joueur
	for lampe in lampes:
		lampe.connect("lampe_allumee", Callable(player, "_on_lampe_allumee"))

	# Initialiser le compteur de lampes dans le joueur
	player.init_lampes()

	# Connecter le signal de fin d'allumage des lampes
	player.connect("all_lamps_on", Callable(self, "_on_all_lampes_allumee"))

func _on_all_lampes_allumee():
	if door:
		print("All lamps are on, door should open now.")
		door.play_door_sound()
		door.enable_transition()
	else:
		print("Erreur : le nœud Door est introuvable.")
