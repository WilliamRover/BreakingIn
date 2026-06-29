class_name Poles extends TileSetGen

@export var lightpole_cast: PackedScene = preload("res://Scenes/Util/Lights/Lightpole/lightpole_cast.tscn")
@export var lightpole_bulb1: PackedScene = preload("res://Scenes/Util/Lights/Lightpole/lightpole_bulb_1.tscn")
@export var lightpole_bulb2: PackedScene = preload("res://Scenes/Util/Lights/Lightpole/lightpole_bulb_2.tscn")
@export var lightpole_beam: PackedScene = preload("res://Scenes/Util/Lights/Lightpole/lightpole_beam.tscn")
# Called when the node enters the scene tree for the first time.

func spawnChild() -> void:
	await GlobalSignal.iniLoaded
	var cells = get_used_cells()
	for cell in cells:
		var data = get_cell_tile_data(cell)
		if data.get_custom_data("lightPole") && DatabaseManager.getLevelProperty("environment", "lightPoleOn"):
			instantiateArea(lightpole_cast, cell)
			if data.get_custom_data("bulb1"):
				instantiateArea(lightpole_bulb1, cell)
				instantiateArea(lightpole_beam, cell, "bulb1")
			elif data.get_custom_data("bulb2"):
				instantiateArea(lightpole_bulb2, cell)
				instantiateArea(lightpole_beam, cell, "bulb2")

func instantiateArea(scene: PackedScene, cell, bulb: String = ""):
	var ins = super(scene, cell)
	
	if scene == lightpole_bulb1 || bulb == "bulb1":
		ins.translate(Vector2(124, -409))
		if bulb == "bulb1":
			ins.scale = Vector2(1, 0.8)
	elif scene == lightpole_bulb2 || bulb == "bulb2":
		ins.translate(Vector2(-117, -283))
		if bulb != "bulb2":
			ins.scale = Vector2(1.85, 1.871)
