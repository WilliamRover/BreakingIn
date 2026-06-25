class_name NearSecurityDoor extends Near

var secDoorId: String = ""
@onready var alarm: AudioStreamPlayer2D = $Alarm

# ID 2
@export var close_door_atlas := Vector2i(1, 0)
@export var open_door_atlas := Vector2i(1, 1)

@export var lockpickMinigame: PackedScene = preload("res://Scenes/Minigame/Lockpick/lock_pick.tscn")
@export var drillLockMinigame: PackedScene = preload("res://Scenes/Minigame/DrillLock/drill_lock_minigame.tscn")
var pickGame: Node
var lock_seed: int = -1
var drillGame: Node
var curPosDrill: Vector2 = Vector2(0, 0)

var isLockPick: bool = false
var isDrilling: bool = false
var firstDrill: bool = true

var powerDown: bool = false
var rebooting: bool = false
func _ready() -> void:
	super()
	GlobalSignal.turnLight.connect(_on_global_light_toggle)
	
func get_available_actions() -> Array[String]:
	var actions: Array[String] = []
	actions.append("Open_Close")
	if locked:
		if PlayerStat.checkItemInLoadout("drill"):
			actions.append("Drill")
		if PlayerStat.checkItemInLoadout("lockPick"):
			actions.append("Picklock")
	return actions

func interactAction() -> void:
	_on_action_button_pressed("Open_Close", floatingOption.get_node("Open_Close"))

func execute_action(action_name: String, button: Button) -> void:
	stopMoving.emit(false)
	match action_name:
		"Open_Close":
			if locked:
				awaitSfx("LockSFX", button)
				showNotif.emit("Seems like it's locked")
			else:
				open = !open
				GlobalSignal.doorWinInteracted.emit(self, open)
				if powerDown == false && rebooting == false:
					alarm.play()
					get_tree().create_timer(1.5).timeout.connect(callPolice)
				if open:
					update_tile_visual(open_door_atlas, 2)
					awaitSfx("OpenDoorSFX", button)
				else:
					update_tile_visual(close_door_atlas, 2)
					awaitSfx("CloseDoorSFX", button)
		"Drill":
			stopMoving.emit(false)
			isDrilling = true
			drillGame = innitMinigame(drillLockMinigame)
			minigameProg = true
			if firstDrill:
				curPosDrill = drillGame.getDrillPos()
			drillGame.setDrillPos(curPosDrill)
			firstDrill = false
			drillGame.lockDrilled.connect(_on_drill_success)
			await drillGame.tree_exited
		"Picklock":
			stopMoving.emit(false)
			isLockPick = true
			minigameProg = true
			pickGame = innitMinigame(lockpickMinigame)
			awaitSfx("lockpickingSFX", button)
			
			if lock_seed == -1:
				lock_seed = pickGame.generateNewGame()
			else:
				pickGame.retryGame(lock_seed)
				
			pickGame.allPinPushed.connect(_on_finished_lockpick.bind(button))
			await pickGame.tree_exited
	stopMoving.emit(true)
	enableFloatingOption()

func _on_finished_lockpick(btn: Button) -> void:
	await get_tree().create_timer(0.55).timeout
	stopMoving.emit(true)
	minigameProg = false
	stopSfx("lockpickingSFX", btn)
	awaitSfx("UnlockSFX", btn)
	if is_instance_valid(pickGame):
		pickGame.queue_free()
	locked = false
	isLockPick = false

func _on_drill_success() -> void:
	await get_tree().create_timer(0.55).timeout
	stopMoving.emit(true)
	minigameProg = false
	locked = false
	if is_instance_valid(drillGame):
		drillGame.queue_free()
	isDrilling = false

func cancelMinigame() -> void:
	if isLockPick:
		stopSfx("lockpickingSFX", btnGlobal)
		isLockPick = false
	if isDrilling:
		curPosDrill = drillGame.getDrillPos()
		isDrilling = false
	closeMinigame()

func _on_global_light_toggle(broadcastedId: String, _overload: bool):
	if secDoorId == broadcastedId:
		powerDown = !powerDown
		if powerDown == false:
			rebooting = true
			await get_tree().create_timer(15).timeout
			rebooting = false
			if powerDown == false && open:
				alarm.play()
		else:
			alarm.stop()

func callPolice() -> void:
	GlobalSignal.triggerCallPoliceSignal()
