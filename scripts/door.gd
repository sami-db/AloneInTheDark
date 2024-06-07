extends Area2D

@export var next_scene: String  # Le chemin de la prochaine scène à charger
@onready var door_sound = $DoorSound
@onready var interaction_label = $InteractionLabel
@onready var interaction_button = $InteractionButton

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))
	interaction_label.visible = false  # Masquer le label au début
	interaction_button.visible = false  # Masquer le bouton au début
	interaction_button.connect("pressed", Callable(self, "_on_interaction_button_pressed"))

func play_door_sound():
	door_sound.play()

func enable_transition():
	interaction_label.visible = true
	interaction_button.visible = true

func _on_body_entered(body):
	if body is Player:
		interaction_label.visible = true  # Afficher le label
		interaction_button.visible = true  # Afficher le bouton

func _on_body_exited(body):
	if body is Player:
		interaction_label.visible = false  # Masquer le label
		interaction_button.visible = false  # Masquer le bouton

func _process(delta):
	if interaction_button.visible and Input.is_action_just_pressed("interact"):
		_on_interaction_button_pressed()

func _on_interaction_button_pressed():
	if next_scene and next_scene != "":
		var scene_path = next_scene
		if ResourceLoader.exists(scene_path):
			get_tree().change_scene_to_file(scene_path)
		else:
			print("Erreur : La scène suivante n'existe pas à l'emplacement spécifié - %s" % scene_path)
	else:
		print("Erreur : next_scene n'est pas défini ou est vide")
