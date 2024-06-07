extends Area2D

signal lampe_allumee

var showInteractionLabel = false
var est_allumee = false

func _ready():
	$PointLight2D.visible = false

func _process(delta):
	$Label.visible = showInteractionLabel
	$SpriteButton.visible = showInteractionLabel
	
	if showInteractionLabel and Input.is_action_just_pressed("activate_lamp") and not est_allumee:
		start_mini_game()

func _on_body_entered(body):
	if body is Player:
		showInteractionLabel = true

func _on_body_exited(body):
	if body is Player:
		showInteractionLabel = false

func start_mini_game():
	var player = get_node_or_null("/root/world/player")
	if player == null:
		player = get_node_or_null("/root/Stage1/player")
	if player == null:
		print("Erreur : Impossible de trouver le nœud Player")
		return
	player.start_mini_game(self)
	print("Mini-game démarré depuis la lampe")

func _on_mini_game_success():
	allumer_lampe()

func allumer_lampe():
	est_allumee = true
	print("lamp activated")
	$PointLight2D.visible = true
	$AnimationPlayer.play("allumer")
	$AnimationPlayerLoop.play("loop_sprite")
	emit_signal("lampe_allumee")
