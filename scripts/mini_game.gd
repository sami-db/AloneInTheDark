extends Control

signal mini_game_success

var is_active = false
var target_angle = 0.0
var current_angle = 0.0
@export var rotation_speed: float = 90.0  # Vitesse de rotation en degrés par seconde

@onready var circle = $Circle
@onready var indicator = $Circle/Indicator

func _ready():
	hide()
	set_process(false)
	print("MiniGame ready")
	
	# Vérifier si les nœuds sont correctement trouvés
	if circle == null:
		print("Erreur : nœud Circle non trouvé")
	else:
		print("Circle trouvé")
		print("Circle visibility: ", circle.visible)
	
	if indicator == null:
		print("Erreur : nœud Indicator non trouvé")
	else:
		print("Indicator trouvé")
		print("Indicator visibility: ", indicator.visible)

	# Vérifier la couche de rendu
	print("MiniGame z_index: %d" % z_index)

func start_mini_game():
	is_active = true
	target_angle = randf() * 360.0
	current_angle = 0.0
	show()
	set_process(true)
	print("MiniGame started")
	print("Target angle: %f" % target_angle)
	print("Current angle: %f" % current_angle)
	print("MiniGame position: %s" % str(global_position))
	print("Circle position: %s" % str(circle.global_position))
	print("Indicator position: %s" % str(indicator.global_position))
	print("MiniGame visibility après show: ", visible)
	print("MiniGame z_index après show: %d" % z_index)

func _process(delta):
	if not is_active:
		return

	# Utiliser la molette de la souris pour ajuster l'angle actuel
	if Input.is_action_pressed("ui_scroll_up"):
		current_angle -= rotation_speed * delta
	elif Input.is_action_pressed("ui_scroll_down"):
		current_angle += rotation_speed * delta

	# Assurez-vous que l'angle reste entre 0 et 360 degrés
	if current_angle < 0:
		current_angle += 360
	elif current_angle >= 360:
		current_angle -= 360

	indicator.rotation_degrees = current_angle

	# Vérifier si la touche E est pressée pour valider la position
	if Input.is_action_just_pressed("activate_lamp"):
		var angle_diff = abs(current_angle - target_angle)
		if angle_diff < 5.0:  # Vous pouvez ajuster cette valeur pour la difficulté
			is_active = false
			hide()
			set_process(false)
			emit_signal("mini_game_success")

func get_potentiometer_value():
	return current_angle
