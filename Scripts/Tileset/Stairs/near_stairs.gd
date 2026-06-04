# DOES NOT EXTENDS NEAR. VERY SPECIAL CASE
class_name NearStairs extends Node2D

@onready var bottom: Area2D = $Bot
@onready var top: Area2D = $Top
@onready var mid: Area2D = $StairZone

@export var floor0Layer := 1
@export var floor1Layer := 2
@export var stairsLayer := 3

func _on_top_body_entered(body: Node2D) -> void:
	if body is Player:
		if body.get_collision_mask_value(floor1Layer) or body.get_collision_mask_value(stairsLayer):
			body.z_index = 1
			body.set_collision_mask_value(floor1Layer, true)
			body.set_collision_mask_value(stairsLayer, true)


func _on_top_body_exited(body: Node2D) -> void:
	if body is Player:
		if body.get_collision_mask_value(floor1Layer) or body.get_collision_mask_value(stairsLayer):
			if mid.overlaps_body(body):
				print("top tru ex")
				body.set_collision_mask_value(floor1Layer, false)
			else:
				print("top f ex")
				#body.z_index = 0
				body.set_collision_mask_value(stairsLayer, false)
			


func _on_bot_body_entered(body: Node2D) -> void:
	if body is Player:
		if body.get_collision_mask_value(floor0Layer) or body.get_collision_mask_value(stairsLayer):
		#print("bot enter")
			body.z_index = 1
			body.set_collision_mask_value(floor0Layer, true)
			body.set_collision_mask_value(stairsLayer, true)


func _on_bot_body_exited(body: Node2D) -> void:
	if body is Player:
		if body.get_collision_mask_value(floor0Layer) or body.get_collision_mask_value(stairsLayer):
			if mid.overlaps_body(body):
				print("bot tru ex")
				body.set_collision_mask_value(floor0Layer, false)
			else:
				print("bot f ex")
				body.z_index = 0
				#body.set_collision_mask_value(floor0Layer, false)
				body.set_collision_mask_value(stairsLayer, false)
