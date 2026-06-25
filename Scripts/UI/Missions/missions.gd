class_name UIMissions extends Control

@export var missionCard: PackedScene = preload("res://Scenes/UI/Missions/mission_card.tscn")
@export var dotBtn: PackedScene = preload("res://Scenes/UI/Missions/dot_button.tscn")

@onready var missionCardContainer: CenterContainer = $MissionCardContainer
@onready var dotContainer: HBoxContainer = $TimelineScroll/DotContainer
@onready var backMenuBtn: Button = $BackToMenu/Button
@onready var missionDetail: Control = $MissionDetail
var missions: Array = []
var currentIdx := 0
var insCard: Node
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	readJson("res://Data/missions.json")
	backMenuBtn.pressed.connect(backToMenu)
	#print(missions)
	if missions.size() > 0:
		instantiateCard()
		instantiateDot()
		updateUi()

func readJson(filePath: String) -> void:
	var file = FileAccess.open(filePath, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	missions = JSON.parse_string(content)
	
func instantiateCard() -> void:
	insCard = missionCard.instantiate()
	missionCardContainer.add_child(insCard)

func instantiateDot() -> void:
	for dot in dotContainer.get_children():
		dot.queue_free()
	for i in range(missions.size()):
		var dot = dotBtn.instantiate()
		dot.pressed.connect(_on_dot_clicked.bind(i))
		dotContainer.add_child(dot)
		
func _input(event: InputEvent) -> void:
	if event is InputEventKey && event.is_pressed():
		if event.keycode == KEY_E:
			changeMission(currentIdx + 1)
		elif event.keycode == KEY_Q:
			changeMission(currentIdx - 1)

func _on_dot_clicked(idx: int) -> void:
	changeMission(idx)

func changeMission(idx: int) -> void:
	if idx >= 0 && idx < missions.size():
		currentIdx = idx
		updateUi()
		
		
func updateUi() -> void:
	var data = missions[currentIdx]
	if !insCard.missionChosen.is_connected(choseMission):
		insCard.missionChosen.connect(choseMission)
	
	var bestTime: float = -1
	var existMission = PlayerStat.data["missionStatus"].filter(func(m): return m.get("missionTitle") == data["title"])
	#print(str(existMission[0]["missionTitle"]["bestTime"]))
	#print(existMission)
	if existMission.size() > 0:
		bestTime = existMission[0]["bestTime"]
	insCard.updateData(data["title"], data["time"], data["place"], data["thumbnail"], data["scenePath"], bestTime)
	for i in range(dotContainer.get_child_count()):
		var dot = dotContainer.get_child(i)
		dot.setActive(i == currentIdx)
		
	await get_tree().process_frame
	var curDot = dotContainer.get_child(currentIdx)
	var screenPosX = size.x / 2
	var dotPosX = curDot.position.x 
	var targetX = screenPosX - dotPosX - 40
	
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(dotContainer, "position:x", targetX, 0.4)

func backToMenu() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu/menu.tscn")

func choseMission() -> void:
	var data = missions[currentIdx]
	missionDetail.assignValues(data["thumbnail"], data["desc"], data["requiredLoadoutDesc"], data["requiredLoadout"])
	missionDetail.visible = true
	#get_tree().change_scene_to_file("res://Scenes/UI/Misc/loading_screen.tscn")
