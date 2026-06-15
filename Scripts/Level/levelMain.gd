class_name LevelMain extends Node2D


# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
	LevelStat.clearData()
	LevelStat.defaultSave()
