extends Node

const SAVE_PATH = "user://level_stat.ini"
var confFile := ConfigFile.new()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	loadGame()

func defaultSave() -> void:
	# create save file for the first time here
	confFile.set_value("missionTitle", "title", "")
	confFile.set_value("completion", "complete", false)
	confFile.set_value("elapsedTime", "time", 0)
	#confFile.set_value("safeCode", "safeCode", [])
	saveGame()

func saveGame() -> void:
	confFile.save(SAVE_PATH)

func loadGame() -> void:
	var exist = confFile.load(SAVE_PATH)
	if exist != OK:
		defaultSave()

func updLevelStat(section: String, key: String, value: Variant) -> void:
	confFile.set_value(section, key, value)
	saveGame()

func getLevelStat(section: String, key:String, value: Variant = null) -> Variant:
	return confFile.get_value(section, key, value)
	
func clearData() -> void:
	confFile.clear()
	saveGame()

#func clearSafe() -> void:
	#for section in confFile.get_sections():
		#if section.begins_with("Safe"):
			#confFile.erase_section(section)
	#saveGame()
