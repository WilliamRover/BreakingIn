class_name RewireGarage extends Minigame

@export var box: PackedScene = preload("res://Scenes/Minigame/RewireGarage/terminal_box.tscn")

@export var startX: float = 62
@export var endX: float = 1290
@export var spawnY: float = 0

@onready var rewireStat: Sprite2D = $RewireStat
var boxSeqHash: Dictionary = {}

signal rewireSuccess()
signal rewireFail()
#var pair := 0
#var wireTipConnect := 0
#
#var tip1: Node2D = null
#var tip2: Node2D = null
#var tips: Array[Node2D] = []
var activeTip: Dictionary = {}
#func _ready() -> void:
	#generateTerminalBox()

func execution() -> void:
	boxSeqHash.clear()
	var numBox = rng.randi_range(4, 7)
	# Shuffling
	#var ranNum: Array = []
	#for i in range(numBox):
		#ranNum.append(i + 1)
	#for i in range(ranNum.size() - 1, 0, -1):
		#var j = boxRng.randi_range(0, i) 
		#var temp = ranNum[i]
		#ranNum[i] = ranNum[j]
		#ranNum[j] = temp
	
	var boxX = 40
	for i in range(numBox):
		var newBox = box.instantiate()
		newBox.wireTipEntered.connect(_on_wire_tip_entered.bind(newBox))
		newBox.wireTipExited.connect(_on_wire_tip_exited.bind(newBox))
		newBox.global_position = Vector2(boxX, 0)
		add_child(newBox)
		boxX += 215
		boxSeqHash[newBox] = 0
		#pinSeqHash[newPin] = ranNum[i]
	#print(boxSeqHash)
	var boxNum = boxSeqHash.keys()
	boxNum.shuffle()
	boxSeqHash[boxNum[0]] = 1
	boxSeqHash[boxNum[1]] = 1
	
	#print(boxSeqHash)
#var sameTip: bool = false
func _on_wire_tip_entered(body: Node2D, boxNode: Node2D):
	activeTip[body] = boxNode
	checkRewireStat()
	#print(pair)

func _on_wire_tip_exited(body: Node2D, boxNode: Node2D):
	if activeTip.has(body) && activeTip[body] == boxNode:
		activeTip.erase(body)
	checkRewireStat()

func checkRewireStat():
	var texture
	var wireTipConnect = activeTip.size()
	var boxNodeConnect = activeTip.values()
	#print(tips)
	if wireTipConnect <= 1:
		texture = load("res://Assets/RewireGarage/rewireNeutral.png")
	if wireTipConnect == 2:
		#print(str(pair) + " " + str(wireTipConnect)+ " " + str(tip1) + " " + str(tip2))
		if boxNodeConnect[0] == boxNodeConnect[1]:
			texture = load("res://Assets/RewireGarage/rewireFail.png")
			rewireFail.emit()
		else:
			var pair = boxSeqHash[boxNodeConnect[0]] + boxSeqHash[boxNodeConnect[1]]
			
			if pair == 2:
				texture = load("res://Assets/RewireGarage/rewireSuccess.png")
				rewireSuccess.emit()
			else:
				texture = load("res://Assets/RewireGarage/rewireFail.png")
				rewireFail.emit()
	elif wireTipConnect >= 3:
		texture = load("res://Assets/RewireGarage/rewireFail.png")
		rewireFail.emit()
	rewireStat.texture = texture
