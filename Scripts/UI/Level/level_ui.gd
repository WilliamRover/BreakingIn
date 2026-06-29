class_name LevelUI extends CanvasLayer

@onready var elapsedTimeLabel: Label = $ElapsedTime
@onready var countdownLabel: Label = $CountdownTimer
@onready var countdownTimer: Timer = $Timer
@onready var pauseOverlay: Control = $PauseOverlay
@onready var missionObjCont: Label = $MissionObjectiveContent

var elapsedTime: float = 0
var elapsedTimeRunning: bool = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	countdownTimer.timeout.connect(_on_timer_timeout)
	countdownLabel.visible = false
	pauseOverlay.visible = false
	#startTimer(10)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !countdownTimer.is_stopped():
		updTime(countdownLabel, countdownTimer.time_left)
	if elapsedTimeRunning:
		elapsedTime += delta
		updTime(elapsedTimeLabel, elapsedTime)

@warning_ignore("integer_division")
func updTime(label: Label, time: float) -> void:
	var totalSec: int = int(time)
	
	var mins: int = totalSec / 60
	var sec: int = totalSec % 60
	
	label.text = "%02d:%02d" % [mins, sec]
	
func startTimer(sec: int) -> void:
	countdownLabel.visible = true
	countdownTimer.wait_time = sec
	countdownTimer.start()
	
func _on_timer_timeout():
	countdownLabel.visible = false


func recordElapsedTime() -> void:
	elapsedTimeRunning = false
	LevelStat.updLevelStat("elapsedTime", "time", elapsedTime)


func setMissionObjectiveContent(cont: String) -> void:
	missionObjCont.text = cont
