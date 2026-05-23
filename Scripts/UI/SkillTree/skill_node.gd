class_name SkillNode extends TextureButton

@export var skillId: String = ""
@export var skillName: String = ""
@export var desc: String = ""
@export var cost := 1
@export var prerequisites: Array[String] = []
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
func checkCondition() -> void:
	if unlocked == true:
		disabled = true
		texture_disabled = texturePathSelected
	elif purchasable == true:
		disabled = false
	else:
		disabled = true
		texture_disabled = texturePathUnselected
