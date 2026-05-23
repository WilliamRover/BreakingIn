extends Node2D
@export var pin: PackedScene = preload("res://Scenes/Minigame/Lockpick/pin.tscn")

@export var startX: float = 80
@export var endX: float = 1290
@export var spawnY: float = 463.0

var lockRng = RandomNumberGenerator.new()
var savedSeed: int
var pinSeqHash: Dictionary = {}
var tempCheck := 1

signal allPinPushed()
# Called when the node enters the scene tree for the first time.
func generateNewLock() -> int:
	lockRng.randomize()
	savedSeed = lockRng.seed
	spawn_random_pins()
	return savedSeed

func retry_saved_lock(old_seed: int) -> void:
	lockRng.seed = old_seed 
	spawn_random_pins()

func spawn_random_pins() -> void:
	pinSeqHash.clear()
	var numPins = lockRng.randi_range(3, 6)
	# Shuffling
	var ranNum: Array = []
	for i in range(numPins):
		ranNum.append(i + 1)
	for i in range(ranNum.size() - 1, 0, -1):
		var j = lockRng.randi_range(0, i) 
		var temp = ranNum[i]
		ranNum[i] = ranNum[j]
		ranNum[j] = temp
	
	var distX = endX - startX
	var spacing = distX / (numPins + 1)
	for i in range(numPins):
		var newPin = pin.instantiate()
		var pinX = startX + (spacing * (i + 1))
		newPin.global_position = Vector2(pinX, spawnY)
		add_child(newPin)
		pinSeqHash[newPin] = ranNum[i]


func _on_pin_zone_pin_enter(body: Node2D) -> void:
	var pinRoot = body.get_parent()
	if pinSeqHash[pinRoot] != tempCheck:
		body.set_deferred("freeze", false)
	else:
		tempCheck += 1
		var sprite = body.get_node("SpritePin")
		$PinPushed.play()
		sprite.modulate = Color(0.353, 0.678, 0.392)
	if tempCheck == pinSeqHash.size() + 1:
		allPinPushed.emit()
