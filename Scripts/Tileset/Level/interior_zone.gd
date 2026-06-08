extends Area2D

@export var transparentLevel: Node2D
@export var curFloorLayer := 1

func _ready() -> void:
	GlobalSignal.playerClimbed.connect(_climbed)
	
func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if body.get_collision_mask_value(1):
			transparentLevel.visible = false


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		if body.get_collision_mask_value(1):
			transparentLevel.visible = true

func _climbed(inside: bool) -> void:
	if inside:
		transparentLevel.visible = false
	else:
		transparentLevel.visible = true
