extends Node2D



func _process(delta):
	$Sprite2D.rotation = deg_to_rad(ArduinoManager.potentiometreUn)
