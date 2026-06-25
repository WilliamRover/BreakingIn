class_name PauseOverlay extends Control

@onready var resumeBtn: Button = $PauseMain/MarginContainer/VBoxContainer/HBoxContainer/Resume
@onready var settingsBtn: Button = $PauseMain/MarginContainer/VBoxContainer/HBoxContainer/Settings
@onready var replayBtn: Button = $PauseMain/MarginContainer/VBoxContainer/HBoxContainer/Replay
@onready var menuBtn: Button = $PauseMain/MarginContainer/VBoxContainer/HBoxContainer/Menu

@onready var settingScreen: Control = $Settings
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	resumeBtn.pressed.connect(resume)
	settingsBtn.pressed.connect(dispSettings)
	replayBtn.pressed.connect(replay)
	menuBtn.pressed.connect(backToMenu)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ESC - PAUSE MENU"):
		#print_stack()
		visible = !visible
		get_tree().paused = !get_tree().paused

func resume() -> void:
	visible = false
	get_tree().paused = false

func dispSettings() -> void:
	settingScreen.visible = true

func replay() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func backToMenu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu/menu.tscn")
