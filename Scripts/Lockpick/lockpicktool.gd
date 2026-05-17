extends CharacterBody2D

func _physics_process(delta: float) -> void:
	# Add the gravity.
	velocity = (get_global_mouse_position() - global_position) / delta
	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		var push_strength: float = 100.0
		# If the thing we hit is the pin...
		if collider is RigidBody2D:
			# Get the direction of the hit (the normal) and push in the exact opposite direction
			var push_direction = -collision.get_normal()
			
			# Apply the physical force to the pin!
			collider.apply_central_impulse(push_direction * push_strength)
