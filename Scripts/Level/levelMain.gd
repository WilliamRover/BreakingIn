class_name LevelMain extends Node2D

@export_file("*.ini") var iniFilePath: String = ""
var gameOverOverlay: PackedScene = preload("res://Scenes/UI/InGame/game_over.tscn")
var gameOverOverlayScene: CanvasLayer = null

var gameCompletedOverlay: PackedScene = preload("res://Scenes/UI/InGame/game_completed.tscn")
var gameCompletedOverlayScene: CanvasLayer = null

var config = ConfigFile.new()

func _enter_tree() -> void:
	gameOverOverlayScene = gameOverOverlay.instantiate()
	gameCompletedOverlayScene = gameCompletedOverlay.instantiate()
	add_child(gameCompletedOverlayScene)
	add_child(gameOverOverlayScene)
	LevelStat.clearData()
	LevelStat.defaultSave()

func _ready() -> void:
	GlobalSignal.policeCalled = false
	GlobalSignal.callPolice.connect(callPolice)
	PlayerStat.resetWireAmount()
	GlobalSignal.safeCracked.connect(safeIsCracked)
	
	if iniFilePath != "":
		DatabaseManager.settingIni.load(iniFilePath)
		GlobalSignal.iniLoaded.emit()


func callPolice() -> void:
	pass

func safeIsCracked(_safe: NearSafe) -> void:
	pass
