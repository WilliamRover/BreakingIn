class_name NearBox extends Near


# ID 3
@export var close_small_box_atlas := Vector2i(0, 0)
@export var open_small_box_atlas := Vector2i(1, 0)
@export var close_big_box_atlas := Vector2i(0, 1)
@export var open_big_box_atlas := Vector2i(1, 1)

var smallBox: bool
var bigBox: bool
var rewire: bool = false
# Lockpick
@export var lockpickMinigame: PackedScene = preload("res://Scenes/Minigame/Lockpick/lock_pick.tscn")
@export var rewireGarageMinigame: PackedScene = preload("res://Scenes/Minigame/RewireGarage/rewire_garage_main.tscn")
@export var drillLockMinigame: PackedScene = preload("res://Scenes/Minigame/DrillLock/drill_lock_minigame.tscn")
@export var shortCircuitMinigame: PackedScene = preload("res://Scenes/Minigame/ShortCircuit/short_circuit_main.tscn")

var pickGame: Node
var lock_seed: int = -1
var rewireGarageGame: Node
var rewire_seed: int = -1
var drillGame: Node
var curPosDrill: Vector2 = Vector2(0, 0)
var shortCircuitGame: Node
var shortCircuit_seed: int = -1

var shortCircuit: bool = false
var powerOn: bool = true

var isLockPick: bool = false
var isRewiring: bool = false
var isDrilling: bool = false
var firstDrill: bool = true
var target_garageId: String = ""
var target_powerId: String = ""
# Rewire

# Overide thingy
func get_available_actions() -> Array[String]:
	var actions: Array[String] = []
	actions.append("Open_Close_Box")
	if locked:
		if PlayerStat.checkItemInLoadout("drill"):
			actions.append("Drill")
		if PlayerStat.checkItemInLoadout("lockPick"):
			actions.append("Picklock")
		if PlayerStat.checkItemInLoadout("crowbar"):
			actions.append("Pry")
	else:
		if open && !rewire && smallBox:
			if PlayerStat.checkItemInLoadout("wirex5") && PlayerStat.checkSufficientWire(1):
				actions.append("Rewire")
		elif open && !rewire && bigBox:
			if !shortCircuit:
				actions.append("SwitchPower")
				if PlayerStat.checkItemInLoadout("wirex5") && PlayerStat.checkSkill("overloadPower") && PlayerStat.checkSufficientWire(1) && PlayerStat.checkItemInLoadout("multimeter"):
					actions.append("ShortCircuit")
	if rewire && open && smallBox:
		actions.append("Open_Close_Garage")
	return actions

func interactAction() -> void:
	_on_action_button_pressed("Open_Close_Box", floatingOption.get_node("Open_Close_Box"))

func execute_action(action_name: String, button: Button) -> void:
	stopMoving.emit(false)
	match action_name:
		"Open_Close_Box":
			if locked:
				awaitSfx("LockSFX", button)
				showNotif.emit("Seems like it's locked")
			else:
				open = !open
				GlobalSignal.doorWinInteracted.emit(self, open)
				if open:
					if smallBox:
						update_tile_visual(open_small_box_atlas, 3)
					else:
						update_tile_visual(open_big_box_atlas, 3)
					awaitSfx("OpenSFX", button)
				else:
					if smallBox:
						update_tile_visual(close_small_box_atlas, 3)
					else:
						update_tile_visual(close_big_box_atlas, 3)
					#update_tile_visual(close_win_atlas, 0)
					awaitSfx("CloseSFX", button)
		"SwitchPower":
			if bigBox:
				GlobalSignal.turnLight.emit(target_powerId, shortCircuit)
				if powerOn:
					awaitSfx("PowerOff", button)
					awaitSfx("ElectricGridDown", button)
					awaitSfx("PowerSwitch", button)
				else:
					awaitSfx("PowerSwitch", button)
					awaitSfx("PowerOn", button)
				powerOn = !powerOn
				#print(target_powerId)
		"ShortCircuit":
			if bigBox:
				isRewiring = true
				stopMoving.emit(false)
				minigameProg = true
				awaitSfx("RewiringSFX", button)
				shortCircuitGame = innitMinigame(shortCircuitMinigame)
				#shortCircuit = true
				
				if shortCircuit_seed == -1:
					shortCircuit_seed = shortCircuitGame.generateNewGame()
				else:
					shortCircuitGame.retryGame(shortCircuit_seed)
					
				shortCircuitGame.overload.connect(_on_finished_shortCircuit.bind(button))
				await shortCircuitGame.tree_exited
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
		"Open_Close_Garage":
			if smallBox:
				GlobalSignal.openGarage.emit(target_garageId)
				#for door in doors:
					#if door.garageId == target_garageId:
						#door.openGarage()
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
		"Pry":
			awaitSfx("PrySFX", button)
			#update_tile_visual(open_win_atlas, 0)
			if smallBox:
				update_tile_visual(open_small_box_atlas, 3)
			else:
				update_tile_visual(open_big_box_atlas, 3)
			locked = false
			open = true
		"Rewire":
			if smallBox:
				isRewiring = true
				stopMoving.emit(false)
				minigameProg = true
				rewireGarageGame = innitMinigame(rewireGarageMinigame)
				awaitSfx("RewiringSFX", button)
				
				if rewire_seed == -1:
					rewire_seed = rewireGarageGame.generateNewGame()
				else:
					rewireGarageGame.retryGame(rewire_seed)
					
				rewireGarageGame.rewireSuccess.connect(_on_rewire_success.bind(button))
				rewireGarageGame.rewireFail.connect(_on_rewire_fail.bind(button))
				await rewireGarageGame.tree_exited
			else:
				# big power box
				rewire = true
	stopMoving.emit(true)
	enableFloatingOption()

func checkTileData():
	super()
	var data = curTileMap.get_cell_tile_data(map_pos)
	smallBox = data.get_custom_data("smallBox")
	bigBox = data.get_custom_data("bigBox")

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

func _on_finished_shortCircuit(flag: bool, btn: Button) -> void:
	await get_tree().create_timer(0.55).timeout
	stopMoving.emit(true)
	minigameProg = false
	stopSfx("RewiringSFX", btn)
	if is_instance_valid(shortCircuitGame):
		shortCircuitGame.queue_free()
	if flag == false:
		if powerOn:
			awaitSfx("PowerOff", btn)
			awaitSfx("ElectricGridDown", btn)
		else:
			awaitSfx("ElectricGridDown", btn)
		powerOn = false
	else:
		awaitSfx("PowerOff", btn)
		awaitSfx("ElectricGridDown", btn)
		awaitSfx("PowerShortCircuit", btn)
		shortCircuit = true
		isRewiring = false
		
	PlayerStat.usedWire()
	GlobalSignal.turnLight.emit(target_powerId, shortCircuit)
func _on_rewire_success(btn: Button) -> void:
	#rewireGarageGame.paused = true
	await get_tree().create_timer(0.55).timeout
	stopMoving.emit(true)
	minigameProg = false
	stopSfx("RewiringSFX", btn)
	awaitSfx("RewireSuccessSFX", btn)
	if is_instance_valid(rewireGarageGame):
		rewireGarageGame.queue_free()
	isRewiring = false
	rewire = true
	PlayerStat.usedWire()
	
func _on_rewire_fail(btn: Button) -> void:
	awaitSfx("RewireFailSFX", btn)

func _on_drill_success() -> void:
	await get_tree().create_timer(0.55).timeout
	stopMoving.emit(true)
	minigameProg = false
	locked = false
	if is_instance_valid(drillGame):
		drillGame.queue_free()
	isDrilling = false

func cancelMinigame() -> void:
	if isRewiring:
		stopSfx("RewiringSFX", btnGlobal)
		isRewiring = false
	if isLockPick:
		stopSfx("lockpickingSFX", btnGlobal)
		isLockPick = false
	if isDrilling:
		curPosDrill = drillGame.getDrillPos()
		isDrilling = false
	closeMinigame()
