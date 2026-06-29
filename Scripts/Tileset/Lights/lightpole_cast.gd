class_name LightPoleCast extends PointLight2D

func _ready() -> void:
	light_mask = 1 << (10 + 1)
