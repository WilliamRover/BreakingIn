class_name SkillTree extends Control

var jsonPath = "res://Data/skills.json"

@onready var treeCanvas: Control = $TreeCanvas
@onready var connectLine: Control = $TreeCanvas/ConnectLine
@onready var skillNodes: Control = $TreeCanvas/SkillNodes

@onready var floatingDesc: Panel = $FloatingDesc
@onready var skillNameFloatDesc: Label = $FloatingDesc/SkillName
@onready var skillDescFloatDesc: Label = $FloatingDesc/SkillDesc
@onready var skillCostFloatDesc: Label = $FloatingDesc/Cost
@onready var skillPoint: Label = $MarginContainer2/VBoxContainer/SkillPoint
@onready var resetSkill: Button = $MarginContainer2/VBoxContainer/ResetSkillTree
@onready var confirmSkill: Button = $MarginContainer2/VBoxContainer/ConfirmSkillTree

@onready var backBtn: Button = $MarginContainer/BackToMenu

var jsonSkillDict: Dictionary = {}
var skillDict: Dictionary = {}
var dragging: bool = false
var selectedSkillId: String = ""
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	confirmSkill.disabled = true
	floatingDesc.hide()
	
	confirmSkill.pressed.connect(_on_confirm_pressed)
	resetSkill.pressed.connect(_on_reset_pressed)
	
	backBtn.pressed.connect(backToMenu)
	loadSkill()
	
	for child in skillNodes.get_children():
		if child is SkillNode:
			var data = jsonSkillDict[child.skillId]
			child.assignData(data)
			
			skillDict[child.skillId] = child
			child.mouse_entered.connect(_on_skill_hover.bind(child))
			child.mouse_exited.connect(_on_skill_unhover)
			child.toggled.connect(_on_skill_toggled.bind(child))
	await get_tree().process_frame
	drawLine()
	updateVisual()

func loadSkill() -> void:
	var file = FileAccess.open(jsonPath, FileAccess.READ)
	var jsonStr = file.get_as_text()
	var parseJson = JSON.parse_string(jsonStr)
	file.close()
	for skill in parseJson:
		jsonSkillDict[skill["id"]] = skill
# Drag the screen
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
	elif event is InputEventMouseMotion && dragging:
		#print("draggg")
		treeCanvas.position += event.relative

# Draw line
func drawLine() -> void:
	var lineThickness = 3.0
	for id in skillDict:
		var curSkill = skillDict[id]
		for reqId in curSkill.prerequisites:
			if skillDict.has(reqId):
				var parentSkill = skillDict[reqId]
				var startPos = parentSkill.position + (parentSkill.size / 2.0)
				var endPos = curSkill.position + (curSkill.size / 2.0)
				
				var distance = startPos.distance_to(endPos)
				var angle = startPos.angle_to_point(endPos)
				
				var rect = ColorRect.new()
				rect.name = reqId + "To" + curSkill.skillId
				rect.z_index = -1
				
				rect.size = Vector2(distance, lineThickness)
				rect.pivot_offset = Vector2(0, lineThickness / 2.0)
				rect.position = startPos - Vector2(0, lineThickness / 2.0)
				rect.rotation = angle
				
				connectLine.add_child(rect)

func updateVisual() -> void:
	skillPoint.text = str(int(PlayerStat.data["skillPoint"])) + " skill points"
	var unlockedArr = PlayerStat.data["skills"]
	
	for id in skillDict:
		var skill = skillDict[id]
		if id in unlockedArr:
			skill.unlocked = true
			skill.purchasable = false
		else:
			var meetReq = false
			if skill.prerequisites.size() == 0:
				meetReq = true 
			else:
				for reqId in skill.prerequisites:
					if reqId in unlockedArr:
						meetReq = true
						break
			skill.unlocked = false
			skill.purchasable = meetReq
		skill.checkCondition()
		for req_id in skill.prerequisites:
			var expectedName = req_id + "To" + skill.skillId
			var line = connectLine.get_node_or_null(expectedName)
			
			if line:
				if skill.unlocked:
					line.color = Color(0.822, 0.822, 0.822, 1.0)
				else:
					line.color = Color(0.387, 0.387, 0.387, 1.0)
		
# Btn press do something
func _on_confirm_pressed() -> void:
	if selectedSkillId == "":
		return
	var skill = skillDict[selectedSkillId]
	PlayerStat.data["skillPoint"] -= skill.cost
	PlayerStat.data["skills"].append(selectedSkillId)
	PlayerStat.saveGame()
	skill.button_pressed = false
	updateVisual()

func _on_reset_pressed() -> void:
	var refundPoints = 0
	for id in PlayerStat.data["skills"]:
		if skillDict.has(id):
			refundPoints += skillDict[id].cost
	
	PlayerStat.data["skillPoint"] += refundPoints
	PlayerStat.data["skills"].clear()
	PlayerStat.saveGame()
	
	get_tree().change_scene_to_file("res://Scenes/UI/SkillTree/baseSkill.tscn")

func _upd_floating_panel(skillNode: SkillNode) -> void:
	skillDescFloatDesc.text = skillNode.desc
	skillNameFloatDesc.text = skillNode.skillName
	skillCostFloatDesc.text = "Cost: " + str(skillNode.cost) + " skill points"
	floatingDesc.global_position = skillNode.global_position + Vector2(skillNode.size.x + 10, 0)
	
func _on_skill_toggled(pressed: bool, skillNode: SkillNode) -> void:
	if pressed:
		if selectedSkillId != "" && selectedSkillId != skillNode.skillId:
			var prevNode = skillDict[selectedSkillId]
			selectedSkillId = ""
			prevNode.button_pressed = false
		selectedSkillId = skillNode.skillId
		_upd_floating_panel(skillNode)
		floatingDesc.show()
		
		if PlayerStat.data["skillPoint"] >= skillNode.cost:
			confirmSkill.disabled = false
	else:
		if selectedSkillId == skillNode.skillId:
			selectedSkillId = ""
			floatingDesc.hide()
			confirmSkill.disabled = true
			
func _on_skill_hover(skillNode: SkillNode) -> void:
	if dragging:
		return
	if selectedSkillId == "":
		_upd_floating_panel(skillNode)
		floatingDesc.show()

func _on_skill_unhover() -> void:
	if selectedSkillId == "":
		floatingDesc.hide()

func backToMenu() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu/menu.tscn")
	
