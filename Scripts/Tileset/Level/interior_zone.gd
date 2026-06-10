class_name InteriorZone extends Area2D

#@export var transparentLevel: Array[Node2D]
@export var curFloorLayer := 1

func _ready() -> void:
	#GlobalSignal.playerClimbed.connect(_climbed)
	pass
	
func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if body.climbing:
			return
		body.inside = true
		if body.onStair:
			return
		#if body.get_collision_mask_value(curFloorLayer):
			#for level in transparentLevel:
				#level.visible = false
		if body.curFloor == curFloorLayer:
			GlobalSignal.updRoofVisibility.emit(curFloorLayer)


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		if body.climbing:
			return
		body.inside = false
		if body.get_collision_mask_value(curFloorLayer):
			if body.onStair == true:
				return
			if body.curFloor == curFloorLayer:
				GlobalSignal.updRoofVisibility.emit(0)

#func _climbed(inside: bool, playerCurFloor: int) -> void:
	#if curFloorLayer != playerCurFloor:
		#return
	#if inside == true:
		##print(transparentLevel)
		#for level in transparentLevel:
			##print(level)
			#level.visible = false
			##print(level.visible)
	#else:
		#for level in transparentLevel:
			#level.visible = true
