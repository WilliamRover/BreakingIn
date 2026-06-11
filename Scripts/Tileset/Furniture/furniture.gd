class_name Furniture extends TileSetGen

@export var nearSafe: PackedScene = preload("res://Scenes/Util/nearSafe.tscn")
@export var nearBookShelf: PackedScene = preload("res://Scenes/Util/nearBookshelf.tscn")

func spawnChild() -> void:
	var cells = get_used_cells()
	for cell in cells:
		var data = get_cell_tile_data(cell)
		#var linkId = data.get_custom_data("linkId")
		if data.get_custom_data("safe"):
			instantiateArea(nearSafe, cell)
		elif data.get_custom_data("bookshelf"):
			instantiateArea(nearBookShelf, cell)
