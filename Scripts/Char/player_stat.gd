extends Node

const SAVE_PATH = "user://player_stat.json"
var data: Dictionary = {}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	loadGame()

func defaultSave() -> void:
	# create save file for the first time here
	data = {
		"level": 1,
		"curXp": 0,
		"skillPoint": 2,
		"unlockMission": ["The rookie"],
		"skills": [],
		"unlockLoadout": [],
		"bagLoadout": [],
		"heldLoadout": []
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

func round_place(num,places):
	return (round(num*pow(10,places))/pow(10,places))
	
func based_log(base, x) -> float:
	return (log(x) / log(base))

func getMaxExp() -> int:
	var curLevel = data["level"]
	var algo = round_place(based_log(55, curLevel) * (curLevel * curLevel) + 1000 * curLevel, 0)
	return int(algo)

func addXp(amount: int) ->void:
	data["curXp"] += amount
	while data["curXp"] >= getMaxExp():
		data["curXp"] -= getMaxExp()
		data["level"] += 1
		data["skillPoint"] += 1
	saveGame()
