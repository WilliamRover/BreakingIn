class_name Ceiling extends TileSetGen

@export var ceilinglight_cast: PackedScene = preload("res://Scenes/Util/Lights/CeilingLight/ceilinglight_cast.tscn")
@export var lightBarBulb1: PackedScene = preload("res://Scenes/Util/Lights/CeilingLight/lightbar1_bulb.tscn")
@export var lightBarBulb2: PackedScene = preload("res://Scenes/Util/Lights/CeilingLight/lightbar2_bulb.tscn")
@export var lightBarBulb3: PackedScene = preload("res://Scenes/Util/Lights/CeilingLight/lightbar3_bulb.tscn")
@export var hangLightBulb: PackedScene = preload("res://Scenes/Util/Lights/CeilingLight/hanglight_bulb.tscn")
@export var domeLightBulb: PackedScene = preload("res://Scenes/Util/Lights/CeilingLight/domelight_bulb.tscn")

var lightGroup: Dictionary = {}
var on: bool = true
#@export var ceilinglight_domelightBulb: PackedScene = preload()
func _ready() -> void:
	GlobalSignal.turnLight.connect(_on_global_light_toggle)
	spawnChild()
	
	
func spawnChild() -> void:
	#await GlobalSignal.iniLoaded
	var cells = get_used_cells()
	for cell in cells:
		var data = get_cell_tile_data(cell)
		var linkId = data.get_custom_data("linkId")
		#print(linkId)
		if !lightGroup.has(linkId):
			lightGroup[linkId] = {"on": true, "pairs": []}
		var castLight = instantiateArea(ceilinglight_cast, cell)
		#if DatabaseManager.getLevelProperty("interior", "lightsOn"):
		var bulb: Node2D = null
	#lightCastIns = ins
		match data.get_custom_data("lightType"):
			"lightBar1":
				bulb = instantiateArea(lightBarBulb1, cell)
			"lightBar2":
				bulb = instantiateArea(lightBarBulb2, cell)
			"lightBar3":
				bulb = instantiateArea(lightBarBulb3, cell)
			"hangLight":
				bulb = instantiateArea(hangLightBulb, cell)
			"domeLight":
				bulb = instantiateArea(domeLightBulb, cell)
	#bulbArr.append(bulb)
	#bulb.set("powerId", linkId)
		if bulb:
			lightGroup[linkId]["pairs"].append({
				"cast": castLight,
				"bulb": bulb
			})
		#if data.get_custom_data("lightPole"):
			#if data.get_custom_data("bulb1"):
				#instantiateArea(lightpole_bulb1, cell)
				#instantiateArea(lightpole_beam, cell, "bulb1")
			#elif data.get_custom_data("bulb2"):
				#instantiateArea(lightpole_bulb2, cell)
				#instantiateArea(lightpole_beam, cell, "bulb2")

func instantiateArea(scene: PackedScene, cell):
	var ins = super(scene, cell)
	match scene:
		ceilinglight_cast:
			ins.translate(Vector2(0, 140))
			ins.scale = Vector2(5, 5)
		lightBarBulb1:
			ins.scale = Vector2(2.1, 1.96)
			ins.translate(Vector2(-2, 14))
		lightBarBulb2:
			ins.scale = Vector2(2.1, 2.1)
			ins.translate(Vector2(-7, 16))
		lightBarBulb3:
			ins.scale = Vector2(2.1, 2.1)
			ins.translate(Vector2(-11, 16))
		hangLightBulb:
			ins.scale = Vector2(1.5, 1.5)
			ins.translate(Vector2(3, 34))
		domeLightBulb:
			ins.scale = Vector2(1.2, 1.2)
			ins.translate(Vector2(0, 14))
	
	return ins
	#print(ins)

func _on_global_light_toggle(broadcastedId: String, overload: bool):
	#print(broadcastedId)
	if lightGroup.has(broadcastedId):
		var group = lightGroup[broadcastedId]
		#print(group["on"])
		if overload:
			group["on"] = false
		else:
			group["on"] = !group["on"]
		for pair in group["pairs"]:
			pair["cast"].visible = group["on"]
			pair["bulb"].visible = group["on"]
	
#func switchLight() -> void:
	#on = !on
	#for cast in castLightArr:
		#cast.visible = on
	#for bulb in bulbArr:
		#bulb.visible = on
