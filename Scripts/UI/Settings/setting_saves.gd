extends Node

const SAVE_PATH = "user://settings.json"
var data: Dictionary = {}

func _ready() -> void:
	loadGame()

func defaultSave() -> void:
	# create save file for the first time here
	data = {
		"masterVol": 100,
		"bgMusicVol": 100,
		"sfxVol": 100
	}
	saveGame()
	
func saveGame() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var jsonStr = JSON.stringify(data, "\t")
		file.store_string(jsonStr)
		file.close()

func loadGame() -> void:
	if !FileAccess.file_exists(SAVE_PATH):
		defaultSave()
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var jsonStr = file.get_as_text()
		file.close()
		var parseData = JSON.parse_string(jsonStr)
		data = parseData
