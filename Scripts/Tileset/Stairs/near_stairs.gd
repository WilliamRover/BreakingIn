# DOES NOT EXTENDS NEAR. VERY SPECIAL CASE
class_name NearStairs extends Node2D

@onready var bottom: Area2D = $Bot
@onready var top: Area2D = $Top

@export var floor0Layer := 1
@export var floor1Layer := 2
@export var stairsLayer := 3

func _on_top_body_entered(body: Node2D) -> void:
	if body is Player:
		body.z_index = 1
		body.set_collision_mask_value(floor1Layer, true)
		body.set_collision_mask_value(stairsLayer, true)


func _on_top_body_exited(body: Node2D) -> void:
	if body is Player:
		if body.global_position.y < top.global_position.y:
			body.set_collision_mask_value(stairsLayer, false)
		else:
			#body.z_index = 0
			body.set_collision_mask_value(floor1Layer, false)


func _on_bot_body_entered(body: Node2D) -> void:
	if body is Player:
		print("bot enter")
		body.z_index = 1
		body.set_collision_mask_value(floor0Layer, true)
		body.set_collision_mask_value(stairsLayer, true)


func _on_bot_body_exited(body: Node2D) -> void:
	if body is Player:
		if body.global_position.y < bottom.global_position.y:
			print("bot tru ex")
			body.set_collision_mask_value(floor0Layer, false)
		else:
			print("bot f ex")
			body.z_index = 0
			#body.set_collision_mask_value(floor0Layer, false)
			body.set_collision_mask_value(stairsLayer, false)
