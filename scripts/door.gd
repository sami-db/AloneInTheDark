extends Area2D

@export var next_scene: String  # Le chemin de la prochaine scène à charger
@onready var door_sound = $DoorSound
@onready var interaction_label = $InteractionLabel
@onready var interaction_button = $InteractionButton

var all_lamps_on = false
var player_nearby = false  # Variable pour suivre si le joueur est à proximité

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))
	interaction_label.visible = false  # Masquer le label au début
	interaction_button.visible = false  # Masquer le bouton au début

	# Connecter le signal du joueur pour détecter quand toutes les lampes sont allumées
	var player = get_node_or_null("/root/Stage1/player")
	if player == null:
		player = get_node_or_null("/root/world/player")
	
	if player:
		player.connect("all_lamps_on", Callable(self, "_on_all_lamps_on"))
	else:
		print("Erreur : Impossible de trouver le nœud Player dans aucun des chemins")

func play_door_sound():
	door_sound.play()

func enable_transition():
	interaction_label.visible = true
	interaction_button.visible = true

func _on_body_entered(body):
	if body is Player:
		player_nearby = true
		interaction_label.visible = true  # Afficher le label
		interaction_button.visible = true  # Afficher le bouton

func _on_body_exited(body):
	if body is Player:
		player_nearby = false
		interaction_label.visible = false  # Masquer le label
		interaction_button.visible = false  # Masquer le bouton

func _process(delta):
	if player_nearby and Input.is_action_just_pressed("interact"):
		_on_interaction_button_pressed()

func _on_interaction_button_pressed():
	print("Interacting with the door")
	if all_lamps_on:
		print("All lamps are on, transitioning to the next scene.")
		if next_scene and next_scene != "":
			var scene_path = next_scene
			if ResourceLoader.exists(scene_path):
				get_tree().change_scene_to_file(scene_path)
			else:
				print("Erreur : La scène suivante n'existe pas à l'emplacement spécifié - %s" % scene_path)
		else:
			print("Erreur : next_scene n'est pas défini ou est vide")
	else:
		print("Toutes les lampes doivent être allumées pour passer la porte.")

func _on_all_lamps_on():
	print("Signal received: all lamps are on")
	all_lamps_on = true
	play_door_sound()
	enable_transition()
