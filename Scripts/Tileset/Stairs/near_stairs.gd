# DOES NOT EXTENDS NEAR. VERY SPECIAL CASE
class_name NearStairs extends Node2D

@onready var bottom: Area2D = $Bot
@onready var top: Area2D = $Top
@onready var mid: Area2D = $StairZone

@export var curFloor := 1
@export var nxtFloor := 2
@export var stairsLayer := 3

var tempPlayer: Player = null
func _ready() -> void:
	var curNode = self
	while curNode != null && curNode != get_tree().root:
		if "targetPhysLayer" in curNode:
			curFloor = curNode.targetPhysLayer
			nxtFloor = curFloor + 1
			break
		curNode = curNode.get_parent()

func _on_top_body_entered(body: Node2D) -> void:
	if body is Player:
		if body.get_collision_mask_value(nxtFloor) or body.get_collision_mask_value(stairsLayer):
			tempPlayer = body
			body.z_index = nxtFloor
			body.set_collision_mask_value(nxtFloor, true)
			body.set_collision_mask_value(stairsLayer, true)


func _on_top_body_exited(body: Node2D) -> void:
	if body is Player && body == tempPlayer:
		if body.get_collision_mask_value(nxtFloor) or body.get_collision_mask_value(stairsLayer):
			if mid.overlaps_body(body):
				#print("top tru ex")
				body.set_collision_mask_value(nxtFloor, false)
			else:
				#print("top f ex")
				#body.z_index = 0
				body.set_collision_mask_value(stairsLayer, false)
				#body.updateLightningFloor(nxtFloor)
				tempPlayer = null
			


func _on_bot_body_entered(body: Node2D) -> void:
	if body is Player:
		if body.get_collision_mask_value(curFloor) or body.get_collision_mask_value(stairsLayer):
		#print("bot enter")
			tempPlayer = body
			body.z_index = curFloor - 1
			body.set_collision_mask_value(curFloor, true)
			body.set_collision_mask_value(stairsLayer, true)


func _on_bot_body_exited(body: Node2D) -> void:
	if body is Player && body == tempPlayer:
		if body.get_collision_mask_value(curFloor) or body.get_collision_mask_value(stairsLayer):
			if mid.overlaps_body(body):
				#print("bot tru ex")
				body.z_index = curFloor
				body.set_collision_mask_value(curFloor, false)
			else:
				#print("bot f ex")
				#body.z_index = 0
				#body.set_collision_mask_value(floor0Layer, false)
				body.set_collision_mask_value(stairsLayer, false)
				body.updateLightningFloor(curFloor)
				tempPlayer = null


func _on_stair_zone_body_entered(body: Node2D) -> void:
	if body is Player && body == tempPlayer:
		body.onStair = true
		#print("player oin stairz")
		#if bottom.overlaps_body(body):
			#GlobalSignal.updRoofVisibility.emit(nxtFloor)
		#elif top.overlaps_body(body):
			#GlobalSignal.updRoofVisibility.emit(curFloor)


func _on_stair_zone_body_exited(body: Node2D) -> void:
	if body is Player && body == tempPlayer:
		body.onStair = false
		if bottom.overlaps_body(body):
			body.updateLightningFloor(curFloor)
			if !body.inside:
				GlobalSignal.updRoofVisibility.emit(0)
			else:
				GlobalSignal.updRoofVisibility.emit(curFloor)
		elif top.overlaps_body(body):
			body.updateLightningFloor(nxtFloor)
			if !body.inside:
				GlobalSignal.updRoofVisibility.emit(0)
			else:
				GlobalSignal.updRoofVisibility.emit(nxtFloor)
