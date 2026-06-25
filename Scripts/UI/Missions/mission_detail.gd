class_name MissionDetail extends Control

@onready var missionImg: TextureRect = $MarginContainer/ColorRect/MarginContainer/VBoxContainer/MissionImg
@onready var descLabel: Label = $MarginContainer/ColorRect/MarginContainer/VBoxContainer/Desc
@onready var recLoadoutLabel: Label = $MarginContainer/ColorRect/MarginContainer/VBoxContainer/RecLoadout

@onready var returnBtn: Button = $MarginContainer/ColorRect/MarginContainer/VBoxContainer/Return
@onready var startBtn: Button = $MarginContainer/ColorRect/MarginContainer/VBoxContainer/Start

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	returnBtn.pressed.connect(pressedReturn)
	startBtn.pressed.connect(pressedStart)

func assignValues(imgPath: String, desc: String, recLoadoutDesc: String, recLoadout: Dictionary) -> void:
	missionImg.texture = load(imgPath)
	descLabel.text = desc
	recLoadoutLabel.text = recLoadoutDesc
	var flag = processRecLoadout(recLoadout)
	if !flag:
		startBtn.disabled = true
	else:
		startBtn.disabled = false

func pressedReturn() -> void:
	self.visible = false

func pressedStart() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/Misc/loading_screen.tscn")

func processRecLoadout(recLoadout: Dictionary) -> bool:
	var neededItems: Array = []
	if recLoadout.has("general"):
		neededItems.append_array(recLoadout["general"])
	for skill in PlayerStat.data["skills"]:
		if recLoadout.has(skill):
			neededItems.append_array(recLoadout[skill])
	
	var playerItems: Array = []
	
	for container in PlayerStat.data["inventory"]["containerOrder"]:
		playerItems.append_array(PlayerStat.data["inventory"]["container"][container]["items"])
	
	#print(neededItems)
	#print(playerItems)
	for item in neededItems:
		if !item in playerItems:
			return false
	return true
