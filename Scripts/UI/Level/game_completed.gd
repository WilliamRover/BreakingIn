class_name GameCompleted extends CanvasLayer

@onready var timeElapsed: Label = $Control/VBoxContainer/TimeElapsed
@onready var replayBtn: Button = $Control/VBoxContainer/HBoxContainer/Replay
@onready var menuBtn: Button = $Control/VBoxContainer/HBoxContainer/Menu
@onready var taskVBox: VBoxContainer = $Control/VBoxContainer/TaskCompleted/Task
@onready var expVBox: VBoxContainer = $Control/VBoxContainer/TaskCompleted/ExpGained

func _ready() -> void:
	replayBtn.pressed.connect(replay)
	menuBtn.pressed.connect(returnToMenu)
	

func replay() -> void:
	get_tree().reload_current_scene()

func returnToMenu() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu/menu.tscn")

@warning_ignore("integer_division")
func gameCompleted() -> void:
	var totalSec: int = int(LevelStat.getLevelStat("elapsedTime", "time"))
	var mins: int = totalSec / 60
	var sec: int = totalSec % 60
	
	LevelStat.updLevelStat("completion", "complete", true)
	timeElapsed.text = "%02d:%02d" % [mins, sec]
	visible = true
	
	var levelTitle: String = LevelStat.getLevelStat("missionTitle", "title")
#	compare best time here
	var existMission = PlayerStat.data["missionStatus"].filter(func(m): return m.get("missionTitle") == levelTitle)
	
	var bestTime: float = -1
	if existMission.size() > 0:
		bestTime = existMission[0]["bestTime"]
	#print(bestTime)
	#print(LevelStat.getLevelStat("elapsedTime", "time"))
	if LevelStat.getLevelStat("elapsedTime", "time") < bestTime:
		#print("stat updated")
		PlayerStat.fetchUpdateLevelStat()
	
	

func addTaskCompleted(task: String, expGained: int) -> void:
	var templateTask: Label = taskVBox.get_child(0)
	var templateExp: Label = expVBox.get_child(0)
	
	var newTask: Label = templateTask.duplicate()
	newTask.visible = true
	newTask.text = task
	
	var newExp: Label = templateExp.duplicate()
	newExp.visible = true
	newExp.text = "+ " + str(expGained) + "XP"
	
	taskVBox.add_child(newTask)
	expVBox.add_child(newExp)
	
	PlayerStat.addXp(expGained)
