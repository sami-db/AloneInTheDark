extends Node2D

@export var scroll_speed_x: float = 0.1
@export var scroll_speed_y: float = 0.0

func _ready():
	var shader_material = $TextureRect.material as ShaderMaterial
	shader_material.set("shader_parameter/scroll_speed_x", scroll_speed_x)
	shader_material.set("shader_parameter/scroll_speed_y", scroll_speed_y)
