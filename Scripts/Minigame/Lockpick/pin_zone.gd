extends Area2D

# Called when the node enters the scene tree for the first time.
signal pinEnter(body: Node2D)
func _ready() -> void:
	pass # Replace with function body.


func _on_body_entered(body: Node2D) -> void:
	if body.name == "PinBody":
		body.set_deferred("freeze", true)
		body.set_deferred("linear_velocity", Vector2.ZERO)
		pinEnter.emit(body)
