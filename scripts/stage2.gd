extends Node

func _ready():
	# Rechercher le joueur dans les deux chemins possibles
	var player = get_node_or_null("/root/Stage1/player")
	if player == null:
		player = get_node_or_null("/root/Stage2/player")
	
	if player:
		player.can_move = true  # Réactiver les contrôles du joueur
	else:
		print("Erreur : Impossible de trouver le nœud Player dans aucun des chemins")
