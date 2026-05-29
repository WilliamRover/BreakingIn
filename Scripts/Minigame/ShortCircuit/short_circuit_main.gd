extends Node2D

@export var box: PackedScene = preload("res://Scenes/Minigame/ShortCircuit/terminal_wire.tscn")

@export var startX: float = 250
@export var endX: float = 1202
@export var spawnY: float = 409

var circuitRng = RandomNumberGenerator.new()
var savedSeed: int
#var pinSeqHash: Dictionary = {}
var tempCheck := 1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawnBox()

func spawnBox() -> void:
	var numBox = 18 #circuitRng.randi_range(10, 20)
	var ranNum: Array = []
	for i in range(numBox):
		ranNum.append(i + 1)
	for i in range(ranNum.size() - 1, 0, -1):
		var j = circuitRng.randi_range(0, i) 
		var temp = ranNum[i]
		ranNum[i] = ranNum[j]
		ranNum[j] = temp
	
	var distX = endX - startX
	var spacing = distX / (numBox + 1)
	for i in range(numBox):
		var newBox = box.instantiate()
		var boxX = startX + (spacing * (i + 1))
		newBox.global_position = Vector2(boxX, spawnY)
		add_child(newBox)
		#pinSeqHash[newPin] = ranNum[i]
