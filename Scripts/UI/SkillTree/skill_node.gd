class_name SkillNode extends TextureButton

@export var skillId: String = ""
var skillName: String = ""
var desc: String = ""
var cost: int = 1
var prerequisites: Array = []
var texturePathSelected: Texture2D
var texturePathUnselected: Texture2D

var unlocked: bool = false
var purchasable: bool = false

func _ready() -> void:
	texturePathSelected = load("res://Assets/SkillTree/" + skillId + "Selected.png")
	texturePathUnselected= load("res://Assets/SkillTree/" + skillId + "Unselected.png")
	texture_normal = texturePathUnselected
	texture_pressed = texturePathSelected
# Called when the node enters the scene tree for the first time.
func assignData(data: Dictionary) -> void:
	skillName = data["skillName"]
	desc = data["desc"]
	cost = int(data["cost"])
	var preSkill: Array = data["prerequisites"]
	prerequisites.assign(preSkill)
	
func checkCondition() -> void:
	if unlocked == true:
		disabled = true
		texture_disabled = texturePathSelected
	elif purchasable == true:
		disabled = false
	else:
		disabled = true
		texture_disabled = texturePathUnselected
