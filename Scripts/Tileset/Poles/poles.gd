class_name Poles extends TileMapLayer

@export var lightpole_cast: PackedScene = preload("res://Scenes/Util/Lights/lightpole_cast.tscn")
@export var lightpole_bulb1: PackedScene = preload("res://Scenes/Util/Lights/lightpole_bulb_1.tscn")
@export var lightpole_bulb2: PackedScene = preload("res://Scenes/Util/Lights/lightpole_bulb_2.tscn")
@export var lightpole_beam: PackedScene = preload("res://Scenes/Util/Lights/lightpole_beam.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawnLightpoles()

func spawnLightpoles() -> void:
	var cells = get_used_cells()
	for cell in cells:
		var data = get_cell_tile_data(cell)
		if data.get_custom_data("lightPole"):
			addChild(lightpole_cast, cell)
			if data.get_custom_data("bulb1"):
				addChild(lightpole_bulb1, cell)
				addChild(lightpole_beam, cell, "bulb1")
			elif data.get_custom_data("bulb2"):
				addChild(lightpole_bulb2, cell)
				addChild(lightpole_beam, cell, "bulb2")

func addChild(scene: PackedScene, cell, bulb: String = "") -> void:
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
	
	if scene == lightpole_bulb1 || bulb == "bulb1":
		ins.translate(Vector2(124, -409))
		if bulb == "bulb1":
			ins.scale = Vector2(1, 0.8)
	elif scene == lightpole_bulb2 || bulb == "bulb2":
		ins.translate(Vector2(-117, -283))
		if bulb != "bulb2":
			ins.scale = Vector2(1.85, 1.871)
	add_child(ins)
