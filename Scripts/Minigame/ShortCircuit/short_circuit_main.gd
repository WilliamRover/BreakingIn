class_name Overload extends Minigame

@export var box: PackedScene = preload("res://Scenes/Minigame/ShortCircuit/terminal_wire.tscn")
@export var boom: PackedScene = preload("res://Scenes/Minigame/ShortCircuit/boom.tscn")
@onready var multimeter: Multimeter = $Multimeter
@export var startX: float = 250
@export var endX: float = 1202
@export var spawnY: float = 409

var boxSeqHash: Dictionary = {}
var tempCheck := 1
var activeMultimeterTip: Dictionary = {}
var activeWireTip: Dictionary = {}

var multiMetering: bool = false
signal overload(flag: bool)
# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#spawnBox()

func execution() -> void:
	var numBox = 18 #circuitRng.randi_range(10, 20)
	var ranNum: Array = []
	for i in range(numBox):
		ranNum.append(i + 1)
	for i in range(ranNum.size() - 1, 0, -1):
		var j = rng.randi_range(0, i)
		var temp = ranNum[i]
		ranNum[i] = ranNum[j]
		ranNum[j] = temp
	
	var distX = endX - startX
	var spacing = distX / (numBox + 1)
	for i in range(numBox):
		var newBox = box.instantiate()
		newBox.wireTipEntered2.connect(_on_wire_tip_entered.bind(newBox))
		newBox.wireTipExited2.connect(_on_wire_tip_exited.bind(newBox))
		var boxX = startX + (spacing * (i + 1))
		newBox.global_position = Vector2(boxX, spawnY)
		add_child(newBox)
		boxSeqHash[newBox] = 0
		#print(newBox)
	var boxNum = boxSeqHash.keys()
	boxNum.shuffle()
	boxSeqHash[boxNum[0]] = 1
	#print(boxSeqHash)

func _on_wire_tip_entered(body: Node2D, origin: Node2D, boxNode: Node2D):
	if origin.get_parent().get_parent().name == "Multimeter":
		activeMultimeterTip[body] = boxNode
	elif origin.get_parent().get_parent().name == "Wire":
		activeWireTip[body] = boxNode

	#print(boxSeqHash[body])
	#print(origin.get_parent().get_parent())
	checkShortCircuitStat()
	#print(pair)

func _on_wire_tip_exited(body: Node2D, origin: Node2D, boxNode: Node2D):
	if activeMultimeterTip.has(body) && activeMultimeterTip[body] == boxNode:
		activeMultimeterTip.erase(body)
		multiMetering = false
	elif activeWireTip.has(body) && activeWireTip[body] == boxNode:
		activeWireTip.erase(body)
	checkShortCircuitStat()
	
func checkShortCircuitStat() -> void:
	if activeMultimeterTip.size() == 1 && !multiMetering:
		multiMetering = true
		#print(activeMultimeterTip.values())
		if boxSeqHash[activeMultimeterTip.values()[0]] == 1:
			multimeter.displayVoltage(false)
		elif boxSeqHash[activeMultimeterTip.values()[0]] == 0:
			multimeter.displayVoltage()
	if activeWireTip.size() == 2:
		var wireTipConnect = activeWireTip.size()
		var boxNodeConnect = activeWireTip.values()
		#print(tips)
		if wireTipConnect <= 1:
			return
		if wireTipConnect == 2:
			#print(str(pair) + " " + str(wireTipConnect)+ " " + str(tip1) + " " + str(tip2))
			if boxNodeConnect[0] == boxNodeConnect[1]:
				return
			else:
				var pair = boxSeqHash[boxNodeConnect[0]] + boxSeqHash[boxNodeConnect[1]]
				if pair == 1:
					overload.emit(true)
					var boomSprite = boom.instantiate()
					boomSprite.global_position = boxNodeConnect[0].global_position + Vector2(50, 0)
					add_child(boomSprite)
					#print("overloaded")
				else:
					overload.emit(false)
					#print("power off")
		elif wireTipConnect >= 3:
			return
