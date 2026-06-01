class_name Stairs extends TileSetGen

@export var nearStair: PackedScene = preload("res://Scenes/Util/nearStairs.tscn")

func spawnChild() -> void:
	var cells = get_used_cells()
	for cell in cells:
		var data = get_cell_tile_data(cell)
		if data.get_custom_data("stairs"):
			instantiateArea(nearStair, cell)
