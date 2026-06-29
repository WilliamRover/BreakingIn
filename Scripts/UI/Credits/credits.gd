class_name Credits extends Control

@onready var backBtn: Button = $MarginContainer/BackToMenu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	backBtn.pressed.connect(backToMenu)

func backToMenu() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu/menu.tscn")
