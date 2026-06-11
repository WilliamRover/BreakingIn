extends Node2D

@export var targetPhysLayer := 2
@export var visionLayer:= 10

func _ready() -> void:
	var tempTilesetDict: Dictionary = {}
	var floorBitmask: int = 1 << (targetPhysLayer - 1)
	var wallBitmask: int = 1 << ((targetPhysLayer -1) + 10)
	var visionBitmask: int = 1 << (visionLayer - 1)
	
	var shadowBitmask: int = floorBitmask | visionBitmask
	for child in get_children():
		if child is TileMapLayer && child.tile_set:
			if child is Wall || Furniture || Ceiling || Stairs:
				child.light_mask = wallBitmask
			else:
				child.light_mask = floorBitmask
			
			var originalTileset = child.tile_set
			if !tempTilesetDict.has(originalTileset):
				var cpy = originalTileset.duplicate()
				if cpy.get_physics_layers_count() > 0:
					cpy.set_physics_layer_collision_layer(0, floorBitmask)
					cpy.set_physics_layer_collision_mask(0, 0)
					
				if cpy.get_occlusion_layers_count() > 0:
					cpy.set_occlusion_layer_light_mask(0, shadowBitmask)
				
				if cpy.get_occlusion_layers_count() > 1:
					cpy.set_occlusion_layer_light_mask(1, shadowBitmask)
				
				tempTilesetDict[originalTileset] = cpy
					
			
				child.tile_set = tempTilesetDict[originalTileset]
				
	recursConfLight(self, floorBitmask, wallBitmask)
	GlobalSignal.updRoofVisibility.connect(changeRoofVisibility)

func recursConfLight(curNode: Node, floorMask: int, wallMask: int) -> void:
	for child in curNode.get_children():
		if child is PointLight2D:
			if child.is_in_group("ShineLights"):
				child.range_item_cull_mask = wallMask
			else:
				child.range_item_cull_mask = floorMask
				if child is not LightPoleCast:
					child.shadow_item_cull_mask = floorMask
		recursConfLight(child, floorMask, wallMask)

func changeRoofVisibility(aboveFloors: int) -> void:
	if aboveFloors == 0:
		visible = true
	else:
		if targetPhysLayer <= aboveFloors:
			visible = true
		else:
			visible = false
