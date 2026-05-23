class_name Menu extends Control

@onready var missionsBtn: Button = $MarginContainer/HBoxContainer/VBoxContainer/Missions
@onready var loadoutBtn: Button = $MarginContainer/HBoxContainer/VBoxContainer/Loadout
@onready var skillBtn: Button = $MarginContainer/HBoxContainer/VBoxContainer/SkillTree
@onready var settingsBtn: Button = $MarginContainer/HBoxContainer/VBoxContainer/Settings
@onready var creditBtn: Button = $MarginContainer/HBoxContainer/VBoxContainer/Credits
@onready var xpBar: ProgressBar = $MarginContainer/HBoxContainer/VBoxContainer2/Exp/XpBar
@onready var level: Label = $MarginContainer/HBoxContainer/VBoxContainer2/Exp/Level
@onready var curXp: Label = $MarginContainer/HBoxContainer/VBoxContainer2/XpTxt
@onready var skillPoint: Label = $MarginContainer/HBoxContainer/VBoxContainer/SkillTree/SkillPoint

func _ready() -> void:
	missionsBtn.pressed.connect(loadScene.bind("Missions"))
	skillBtn.pressed.connect(loadScene.bind("SkillTree"))
	skillPoint.text = str(int(PlayerStat.data["skillPoint"]))
	updateXp()
	
func loadScene(sceneName: String) -> void:
	match sceneName:
		"Missions":
			get_tree().change_scene_to_file("res://Scenes/UI/Missions/missions.tscn")
		"SkillTree":
			if PlayerStat.data["skills"].is_empty():
				get_tree().change_scene_to_file("res://Scenes/UI/SkillTree/baseSkill.tscn")
				return
			get_tree().change_scene_to_file("res://Scenes/UI/SkillTree/skillTree.tscn")
func updateXp() -> void:
	level.text = "Level " + str(int(PlayerStat.data["level"]))
	xpBar.max_value = PlayerStat.getMaxExp()
	xpBar.value = PlayerStat.data["curXp"]
	curXp.text = str(int(PlayerStat.data["curXp"])) + " / " + str(PlayerStat.getMaxExp()) + " XP"
