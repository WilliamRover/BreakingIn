class_name GameOver extends CanvasLayer

@onready var timeElapsed: Label = $GameOver/VBoxContainer/TimeElapsed
@onready var replayBtn: Button = $GameOver/VBoxContainer/HBoxContainer/Replay
@onready var menuBtn: Button = $GameOver/VBoxContainer/HBoxContainer/Menu

func _ready() -> void:
	replayBtn.pressed.connect(replay)
	menuBtn.pressed.connect(returnToMenu)
	

func replay() -> void:
	get_tree().reload_current_scene()

func returnToMenu() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu/menu.tscn")

@warning_ignore("integer_division")
func gameOver() -> void:
	var totalSec: int = int(LevelStat.getLevelStat("elapsedTime", "time"))
	var mins: int = totalSec / 60
	var sec: int = totalSec % 60
	
	timeElapsed.text = "%02d:%02d" % [mins, sec]
	visible = true
