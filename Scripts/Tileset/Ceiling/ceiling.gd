class_name Ceiling extends TileSetGen

@export var ceilinglight_cast: PackedScene = preload("res://Scenes/Util/Lights/CeilingLight/ceilinglight_cast.tscn")
@export var lightBarBulb1: PackedScene = preload("res://Scenes/Util/Lights/CeilingLight/lightbar1_bulb.tscn")
@export var lightBarBulb2: PackedScene = preload("res://Scenes/Util/Lights/CeilingLight/lightbar2_bulb.tscn")
@export var lightBarBulb3: PackedScene = preload("res://Scenes/Util/Lights/CeilingLight/lightbar3_bulb.tscn")
@export var hangLightBulb: PackedScene = preload("res://Scenes/Util/Lights/CeilingLight/hanglight_bulb.tscn")
@export var domeLightBulb: PackedScene = preload("res://Scenes/Util/Lights/CeilingLight/domelight_bulb.tscn")
#@export var ceilinglight_domelightBulb: PackedScene = preload()

func spawnChild() -> void:
	var cells = get_used_cells()
	for cell in cells:
		var data = get_cell_tile_data(cell)
		instantiateArea(ceilinglight_cast, cell)
		match data.get_custom_data("lightType"):
			"lightBar1":
				instantiateArea(lightBarBulb1, cell)
			"lightBar2":
				instantiateArea(lightBarBulb2, cell)
			"lightBar3":
				instantiateArea(lightBarBulb3, cell)
			"hangLight":
				instantiateArea(hangLightBulb, cell)
			"domeLight":
				instantiateArea(domeLightBulb, cell)
		#if data.get_custom_data("lightPole"):
			#if data.get_custom_data("bulb1"):
				#instantiateArea(lightpole_bulb1, cell)
				#instantiateArea(lightpole_beam, cell, "bulb1")
			#elif data.get_custom_data("bulb2"):
				#instantiateArea(lightpole_bulb2, cell)
				#instantiateArea(lightpole_beam, cell, "bulb2")

func instantiateArea(scene: PackedScene, cell):
	super(scene, cell)
	match scene:
		ceilinglight_cast:
			globalIns.translate(Vector2(0, 140))
			globalIns.scale = Vector2(5, 5)
		lightBarBulb1:
			globalIns.scale = Vector2(2.1, 1.96)
			globalIns.translate(Vector2(-2, 14))
		lightBarBulb2:
			globalIns.scale = Vector2(2.1, 2.1)
			globalIns.translate(Vector2(-7, 16))
		lightBarBulb3:
			globalIns.scale = Vector2(2.1, 2.1)
			globalIns.translate(Vector2(-11, 16))
		hangLightBulb:
			globalIns.scale = Vector2(1.5, 1.5)
			globalIns.translate(Vector2(3, 34))
		domeLightBulb:
			globalIns.scale = Vector2(1.2, 1.2)
			globalIns.translate(Vector2(0, 14))
	#print(globalIns)
