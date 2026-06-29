class_name TileSetGen extends TileMapLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_parent().ready
	spawnChild()

#Override this thing
func spawnChild() -> void:
	pass

func instantiateArea(scene: PackedScene, cell) -> Node2D:
	var ins = scene.instantiate()
	#globalIns = ins
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
	return ins
