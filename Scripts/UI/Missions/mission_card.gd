class_name MissionCard extends TextureButton

@onready var titleLabel: Label = $MarginContainer/VBoxContainer/HBoxContainer/Title
@onready var timeLabel: Label = $MarginContainer/VBoxContainer/Time
@onready var locationLabel: Label = $MarginContainer/VBoxContainer/Location
@onready var bestTimeLabel: Label = $MarginContainer/VBoxContainer/HBoxContainer/BestTime
@onready var missionLocked: Control = $MissionLocked
@onready var requirement: Label = $MissionLocked/VBoxContainer/Required
var curScenePath: String = ""

signal missionChosen()

func _ready() -> void:
	bestTimeLabel.visible = false
	missionLocked.visible = false
# Called when the node enters the scene tree for the first time.
func updateData(
	title: String, 
	time: String, 
	location: String, 
	thumbnailPath: String, 
	scenePath: String, 
	required: String,
	missionUnlock: bool,
	bestTime: float) -> void:
	
	
	titleLabel.text = title
	timeLabel.text = time
	locationLabel.text = location
	texture_normal = load(thumbnailPath)
	#pressed.connect(loadScene.bind(scenePath))
	curScenePath = scenePath
	requirement.text = required
	if !missionUnlock:
		missionLocked.visible = true
	else:
		missionLocked.visible = false
	
	if bestTime != -1:
		var bestTimeInt = int(bestTime)
		var mins: int = bestTimeInt / 60
		var sec: int = bestTimeInt % 60
		bestTimeLabel.text = "Best time: " + "%02d:%02d" % [mins, sec]
		bestTimeLabel.visible = true
	else:
		bestTimeLabel.visible = false

func _pressed() -> void:
	GlobalSignal.targetScenePath = curScenePath
	missionChosen.emit()
