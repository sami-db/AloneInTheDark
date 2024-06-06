extends Node2D

@onready var camera = $Camera2D  # Assurez-vous que ce chemin est correct pour votre Camera2D
@onready var animation_player = $AnimationPlayer  # Assurez-vous que ce chemin est correct pour votre AnimationPlayer
@onready var player = $player  # Assurez-vous que ce chemin est correct pour votre joueur
@onready var spawn_sprite = $SpawnSprite  # Le sprite ou AnimationPlayer pour l'animation de spawn
@onready var point_light = $Node2D/PointLight2D  # Assurez-vous que ce chemin est correct pour votre PointLight2D

func _ready():
	if camera:
		camera.make_current()  # Forcer la caméra de la scène à être la caméra active
		print("Scene camera is now active")

	if player and animation_player and spawn_sprite and point_light:
		print("Player, AnimationPlayer, SpawnSprite, and PointLight2D found")
		disable_player_point_lights()
		player.visible = false  # Masquer le joueur au début
		point_light.visible = true  # Activer le PointLight2D au début
		start_spawn_animation()
	else:
		print("Erreur : Player, AnimationPlayer, SpawnSprite, ou PointLight2D non trouvé")

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
