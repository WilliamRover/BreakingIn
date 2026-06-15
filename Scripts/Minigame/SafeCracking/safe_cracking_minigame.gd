class_name SafeGame extends Node2D

@onready var safeDial: Sprite2D = $SafeDial
@onready var safeTurnSfx: AudioStreamPlayer = $SafeTurn
@onready var safeCorrectSfx: AudioStreamPlayer = $SafeCorrect
@onready var safeLockedSfx: AudioStreamPlayer = $SafeLocked
@onready var safeUnlockedSfx: AudioStreamPlayer = $SafeUnlocked

@onready var passCodeLabel: Label = $Code

@export var deg: float = 3.6

@export var holdTimeReq: float = 0.6
@export var spinMultiplier: float = 3
@export var tickTimeReq: float = 0.1

var safeId: String = ""

var holdTime: float = 0
var tickTime: float = 0

var code: Array[String] = [" _ _", " _ _", " _ _"]
var ranCode: Array[String] = []

var turn := 0
var safeNum := 0
#var startFlag := true

var lastDir := 0
var leftRotate := 0

var colorTween: Tween

signal safeCracked()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#generateSafeCode()
	
	pass
	
func loadSafeData(passId: String) -> void:
	print(safeId)
	safeId = passId
	var loadCode = LevelStat.getLevelStat(safeId, "safeCode", ["00", "00", "00"])
	ranCode.assign(loadCode)
	print(ranCode)
	
func _process(delta: float) -> void:
	var dir: = 0
	
	if Input.is_action_pressed("PLAYER - A"):
		dir = 1
	elif Input.is_action_pressed("PLAYER - D"):
		dir = -1
		
	if dir != 0:
		if lastDir != 0 && lastDir != dir:
			if turn < 3:
				if (turn % 2 == 0 && dir == -1) || (turn % 2 != 0 && dir == 1):
					turn += 1
					if turn == 3:
						checkCode()
		lastDir = dir
		if Input.is_action_just_pressed("PLAYER - A") || Input.is_action_just_pressed("PLAYER - D"):
			holdTime = 0
			tickTime = tickTimeReq
			doStuff(dir, false)
		else:
			holdTime += delta
			if holdTime >= holdTimeReq:
				tickTime -= delta
				if tickTime <= 0:
					doStuff(dir, true)
					tickTime = tickTimeReq
				
	else:
		holdTime = 0

func doStuff(dir: int, fast: bool) -> void:
	#if dir == 1:
		#if startFlag:
			#startFlag = false
	#elif dir == -1:
		#if startFlag:
			#return
	if fast:
		safeDial.rotation_degrees += deg * dir * spinMultiplier
		safeNum -= dir * spinMultiplier
	else:
		safeDial.rotation_degrees += deg * dir
		safeNum -= dir
	safeTurnSfx.play()
			
	if safeNum < 0:
		safeNum += 100
	if safeNum > 99:
		safeNum -= 100
	
	numToStr(turn, safeNum)
	if turn < 3:
		if safeNum == int(ranCode[turn]):
			correctCode()
	if dir == 1:
		if fast:
			leftRotate += spinMultiplier
		else:
			leftRotate += 1
		if leftRotate >= 300:
			resetSafe()
	else:
		leftRotate = 0	
			
	#turn += 1

func correctCode() -> void:
	safeCorrectSfx.play()
	if colorTween && colorTween.is_valid():
		colorTween.kill()
	colorTween = create_tween()
	passCodeLabel.modulate = Color.WEB_GREEN
	colorTween.tween_property(passCodeLabel, "modulate", Color.WHITE, 0.75).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)

func resetSafe() -> void:
	turn = 0
	leftRotate = 0
	lastDir = 0
	code = [" _ _", " _ _", " _ _"]
	passCodeLabel.text = code[0] + code[1] + code[2]
	passCodeLabel.modulate = Color.WHITE
	
# pass code has 6 numbers total. Each dial turn returns 2 numbers (so 3 turns)
func numToStr(turn: int, number: int) -> void:
	if turn >= 3:
		return
	if number < 10:
		code[turn] = " 0 " + str(number)
	else:
		var strNum = str(number)
		code[turn] = " " + strNum[0] + " " + strNum[1]
	passCodeLabel.text = code[0] + code[1] + code[2]
	
func checkCode() -> bool:
	var safeCode: Array = LevelStat.getLevelStat(safeId, "safeCode", [])
	var correct: bool = true
	for i in range(len(code)):
		var playerCode = code[i].replace(" ", "")
		if playerCode != safeCode[i]:
			correct = false
			break
	
	if correct:
		correctCode()
		safeUnlockedSfx.play()
		safeCracked.emit()
		return true
	else:
		safeLockedSfx.play()
		resetSafe()
		return false
	
