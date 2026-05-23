class_name DotBtn extends Button

func setActive(active: bool) -> void:
	if active:
		custom_minimum_size = Vector2(64, 64) 
		modulate = Color(0.9, 0.9, 0.9)
	else:
		custom_minimum_size = Vector2(50, 50)
		modulate = Color(0.5, 0.5, 0.5)
