extends Node

const SAVE_PATH = "user://player_stat.json"
var data: Dictionary = {}
var wire := 5
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	loadGame()

func defaultSave() -> void:
	# create save file for the first time here
	data = {
		"level": 1,
		"curXp": 0,
		"skillPoint": 2,
		"unlockMission": ["The rookie (TUTORIAL)"],
		"missionStatus": [
			{
				"missionTitle": "exampleName",
				"completion": true,
				"bestTime": 30.2
			}
		],
		"skills": [],
		"inventory": {
			"availableLoadout": ["lockPick", "multimeter", "wirex5", "crowbar", "drill", "flashlight"],
			"containerOrder": ["heldLoadout", "bagLoadout", "beltLoadout"],
			"container": {
				"heldLoadout": {
					"name": "On body",
					"capacity": 6,
					"items": []
				},
				"bagLoadout": {
					"name": "Backpack",
					"capacity": 20,
					"items": []
				},
				"beltLoadout":  {
					"name": "Belt",
					"capacity": 4,
					"items": []
				}
			}
		}
	}
	saveGame()
func saveGame() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var jsonStr = JSON.stringify(data, "\t")
		file.store_string(jsonStr)
		file.close()

func loadGame() -> void:
	#print_stack()
	if !FileAccess.file_exists(SAVE_PATH):
		defaultSave()
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var jsonStr = file.get_as_text()
		file.close()
		var parseData = JSON.parse_string(jsonStr)
		data = parseData
		wire = 5

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

func addUpdMissionStatus(missionTitle: String, timeElapsed: float, completion: bool) -> void:
	var existMission = PlayerStat.data["missionStatus"].filter(func(m): return m.get("missionTitle") == missionTitle)
	#print(existMission)
	if existMission.size() > 0:
		#print("best time updated")
		existMission[0]["bestTime"] = timeElapsed
		#print(data["missionStatus"])
		saveGame()
		return
	
	data["missionStatus"].append({
		"missionTitle": missionTitle,
		"completion": completion,
		"bestTime": timeElapsed
	})
	saveGame()

func fetchUpdateLevelStat() -> void:
	var title: String = LevelStat.getLevelStat("missionTitle", "title")
	var time: float = LevelStat.getLevelStat("elapsedTime", "time")
	var completion: bool = LevelStat.getLevelStat("completion", "complete")
	#print(time)
	addUpdMissionStatus(title, time, completion)


func unlockNextMission(missionTitle: String) -> void:
	if data["unlockMission"].has(missionTitle):
		return
	data["unlockMission"].append(missionTitle)
	saveGame()

func checkItemInLoadout(item: String) -> bool:
	if data["inventory"]["container"]["heldLoadout"]["items"].has(item): return true
	if data["inventory"]["container"]["bagLoadout"]["items"].has(item): return true
	if data["inventory"]["container"]["beltLoadout"]["items"].has(item): return true
	return false
	
func checkSkill(skill: String) -> bool:
	if data["skills"].has(skill): return true
	return false

func usedWire() -> void:
	wire -= 1

func checkSufficientWire(amount: int) -> bool:
	if wire >= amount:
		return true
	return false

func resetWireAmount() -> void:
	wire = 5

func checkMissionAvailable(mission: String) -> bool:
	if data["unlockMission"].has(mission):
		return true
	return false
