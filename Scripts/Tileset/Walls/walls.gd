class_name Wall extends TileSetGen

@export var nearWindow: PackedScene = preload("res://Scenes/Util/nearWindows.tscn")
@export var nearDoor: PackedScene = preload("res://Scenes/Util/nearDoors.tscn")
@export var nearWall: PackedScene = preload("res://Scenes/Util/nearWall.tscn")
@export var nearBoxes: PackedScene = preload("res://Scenes/Util/nearBoxes.tscn")
@export var nearGarage: PackedScene = preload("res://Scenes/Util/nearGarage.tscn")
@export var nearSecDoor: PackedScene = preload("res://Scenes/Util/nearSecurityDoor.tscn")
# Called when the node enters the scene tree for the first time.
func spawnChild() -> void:
	var cells = get_used_cells()
	for cell in cells:
		var data = get_cell_tile_data(cell)
		var linkId = data.get_custom_data("linkId")
		if data.get_custom_data("isWindow"):
			instantiateArea(nearWindow, cell)
		elif data.get_custom_data("garageDoor"):
			var garageIns = instantiateArea(nearGarage, cell)
			garageIns.set("garageId", linkId)
		elif data.get_custom_data("isDoor"):
			instantiateArea(nearDoor, cell)
		elif data.get_custom_data("powerbox"):
			var boxIns = instantiateArea(nearBoxes, cell)
			if data.get_custom_data("smallBox"):
				boxIns.set("target_garageId", linkId)
			else:
				boxIns.set("target_powerId", linkId)
		elif data.get_custom_data("securityDoor"):
			var secDoorIns = instantiateArea(nearSecDoor, cell)
			secDoorIns.set("secDoorId", linkId)
		else:
			if data.get_custom_data("tree"):
				continue
			instantiateArea(nearWall, cell)
func clearArea2D():
	for child in get_children():
		if child is Area2D:
			child.queue_free()
