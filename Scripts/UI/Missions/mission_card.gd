class_name MissionCard extends TextureButton

@onready var titleLabel: Label = $MarginContainer/VBoxContainer/Title
@onready var timeLabel: Label = $MarginContainer/VBoxContainer/Time
@onready var locationLabel: Label = $MarginContainer/VBoxContainer/Location
var curScenePath: String = ""
# Called when the node enters the scene tree for the first time.
func updateData(title: String, time: String, location: String, thumbnailPath: String, scenePath: String) -> void:
	titleLabel.text = title
	timeLabel.text = time
	locationLabel.text = location
	texture_normal = load(thumbnailPath)
	#pressed.connect(loadScene.bind(scenePath))
	curScenePath = scenePath

func _pressed() -> void:
	GlobalSignal.targetScenePath = curScenePath
	get_tree().change_scene_to_file("res://Scenes/UI/Misc/loading_screen.tscn")
