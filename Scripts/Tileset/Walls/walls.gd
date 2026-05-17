class_name Wall extends TileMapLayer

@export var nearWindow: PackedScene = preload("res://Scenes/Util/nearWindows.tscn")
@export var nearDoor: PackedScene = preload("res://Scenes/Util/nearDoors.tscn")
@export var nearWall: PackedScene = preload("res://Scenes/Util/nearWall.tscn")
@export var nearBoxes: PackedScene = preload("res://Scenes/Util/nearBoxes.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	windowsArea()

func windowsArea() -> void:
	var cells = get_used_cells()
	for cell in cells:
		var data = get_cell_tile_data(cell)
		if data.get_custom_data("isWindow"):
			instantiateArea(nearWindow, cell)
		if data.get_custom_data("isDoor"):
			instantiateArea(nearDoor, cell)
		if data.get_custom_data("powerbox"):
			instantiateArea(nearBoxes, cell)
		else:
			instantiateArea(nearWall, cell)
func clearArea2D():
	for child in get_children():
		if child is Area2D:
			child.queue_free()

func instantiateArea(scene: PackedScene, cell) -> void:
	var ins = scene.instantiate()
	var alt_id = get_cell_alternative_tile(cell)
	
	var is_flipped_h = bool(alt_id & TileSetAtlasSource.TRANSFORM_FLIP_H)
	var is_flipped_v = bool(alt_id & TileSetAtlasSource.TRANSFORM_FLIP_V)
	var is_transposed = bool(alt_id & TileSetAtlasSource.TRANSFORM_TRANSPOSE)
	
	var tile_transform = Transform2D()
	
	if is_transposed:
		tile_transform.x = Vector2(0, 1)
		tile_transform.y = Vector2(1, 0)
	else:
		tile_transform.x = Vector2(1, 0)
		tile_transform.y = Vector2(0, 1)
	if is_flipped_h:
		tile_transform.x *= -1
	if is_flipped_v:
		tile_transform.y *= -1
	ins.transform = tile_transform
	ins.position = map_to_local(cell)
	#ins.translate(Vector2(-40, 10))
	
	add_child(ins)
