extends Node

var itemsJsonPath = "res://Data/items.json"
var skillsJsonPath = "res://Data/skills.json"
var missionsJsonPath = "res://Data/missions.json"

var items: Array = []
var skills: Dictionary = {}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_load_items()
	_load_skills()

func _load_items() -> void:
	var file = FileAccess.open(itemsJsonPath, FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) == TYPE_ARRAY:
		items = parsed

func _load_skills() -> void:
	var file = FileAccess.open(skillsJsonPath, FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) == TYPE_ARRAY:
		for skill in parsed:
			skills[skill["id"]] = skill
