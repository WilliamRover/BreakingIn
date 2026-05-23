class_name BaseSkill extends Control

# Drag your buttons from the Scene Tree here
@onready var mechanicalEngBtn: TextureButton = $HBoxContainer/ME
@onready var electricalEngBtn: TextureButton = $HBoxContainer/EE
@onready var baseSkillContainer: HBoxContainer = $HBoxContainer
@onready var floatingDesc: Panel = $FloatingDesc
@onready var floatSkillName: Label = $FloatingDesc/SkillName
@onready var floatSkillDesc: Label = $FloatingDesc/SkillDesc
@onready var floatingSkillCost: Label = $FloatingDesc/Cost

@onready var backBtn: Button = $MarginContainer/BackToMenu
var skillDict: Dictionary = {}
var dragging: bool = false
var selectedSkillId: String = ""

func _ready() -> void:
	mechanicalEngBtn.pressed.connect(_on_base_skill_selected.bind("picklock")) 
	electricalEngBtn.pressed.connect(_on_base_skill_selected.bind("rewire"))
	backBtn.pressed.connect(backToMenu)
	for child in baseSkillContainer.get_children():
		if child is SkillNode:
			skillDict[child.skillId] = child
			child.mouse_entered.connect(_on_skill_hover.bind(child))
			child.mouse_exited.connect(_on_skill_unhover)

func _on_base_skill_selected(chosenSkillId: String) -> void:
	PlayerStat.data["skills"].append(chosenSkillId)
	PlayerStat.data["skillPoint"] -= 2
	PlayerStat.saveGame()
	get_tree().change_scene_to_file("res://Scenes/UI/SkillTree/skillTree.tscn")

func backToMenu() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu/menu.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			dragging = true
			#print("drag true")
			if selectedSkillId != "":
				skillDict[selectedSkillId].button_pressed = false
		else:
			#print("drag false")
			dragging = false

func _on_skill_hover(skillNode: SkillNode) -> void:
	if dragging:
		return
	if selectedSkillId == "":
		_upd_floating_panel(skillNode)
		floatingDesc.show()

func _on_skill_unhover() -> void:
	if selectedSkillId == "":
		floatingDesc.hide()
	
func _upd_floating_panel(skillNode: SkillNode) -> void:
	floatSkillName.text = skillNode.skillName
	floatSkillDesc.text = skillNode.desc
	floatingSkillCost.text = "Cost: " + str(skillNode.cost) + " skill points"
	floatingDesc.global_position = skillNode.global_position + Vector2(skillNode.size.x + 10, 0)
	
	
