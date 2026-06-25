class_name NearWindow extends Near

# ID 0
@export var close_win_atlas := Vector2i(0, 1)
@export var open_win_atlas := Vector2i(0, 2)
@export var broken_win_atlas := Vector2i(0, 3)

@export var lockpickMinigame: PackedScene = preload("res://Scenes/Minigame/Lockpick/lock_pick.tscn")
@export var drillLockMinigame: PackedScene = preload("res://Scenes/Minigame/DrillLock/drill_lock_minigame.tscn")
var pickGame: Node
var lock_seed: int = -1
var drillGame: Node
var curPosDrill: Vector2 = Vector2(0, 0)

var isLockPick: bool = false
var isDrilling: bool = false
var firstDrill: bool = true

@onready var pointA: Marker2D = $PointA
@onready var pointB: Marker2D = $PointB

var curtain: bool
# Overide thingy
func get_available_actions() -> Array[String]:
	var actions: Array[String] = []
	actions.append("Open_Close")
	if locked:
		if PlayerStat.checkItemInLoadout("drill"):
			actions.append("Drill")
		if PlayerStat.checkItemInLoadout("lockPick"):
			actions.append("Picklock")
		if PlayerStat.checkItemInLoadout("crowbar"):
			actions.append("Pry")
		if PlayerStat.checkSkill("breaker"):
			actions.append("Kick_Break")
	else:
		if open:
			actions.append("Climb")
			
	return actions

func interactAction() -> void:
	if isBroken:
		showNotif.emit("Nah, window is broken")
	else:
		if !isBroken:
			_on_action_button_pressed("Open_Close", floatingOption.get_node("Open_Close"))

func execute_action(action_name: String, button: Button) -> void:
	stopMoving.emit(false)
	match action_name:
		"Open_Close":
			if isBroken:
				showNotif.emit("Nah, window is broken")
				return
			if locked:
				awaitSfx("LockedSFX", button)
				showNotif.emit("Seems like it's locked")
			else:
				open = !open
				GlobalSignal.doorWinInteracted.emit(self, open)
				if open:
					update_tile_visual(open_win_atlas, 0)
					awaitSfx("OpenWinSFX", button)
				else:
					update_tile_visual(close_win_atlas, 0)
					awaitSfx("CloseWinSFX", button)
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
		"Climb":
			climb()
			awaitSfx("ClimbThroughSFX", button)
		"Picklock":
			stopMoving.emit(false)
			minigameProg = true
			pickGame = innitMinigame(lockpickMinigame)
			awaitSfx("lockpickingSFX", button)
			isLockPick = true
			if lock_seed == -1:
				lock_seed = pickGame.generateNewGame()
			else:
				pickGame.retryGame(lock_seed)
				
			pickGame.allPinPushed.connect(_on_finished_lockpick.bind(button))
			await pickGame.tree_exited
		"Kick_Break":
			awaitSfx("SmashSFX", button)
			update_tile_visual(broken_win_atlas, 0)
			isBroken = true
			locked = false
			open = true
		"Pry":
			awaitSfx("PrySFX", button)
			locked = false
			if !PlayerStat.checkSkill("pryDoor"):
				update_tile_visual(open_win_atlas, 0)
				open = true
		#"Curtain":
			#if curtain:
				#awaitSfx("OpenCurtainSFX", button)
	stopMoving.emit(true)
	enableFloatingOption()
	
func _on_finished_lockpick(btn: Button) -> void:
	await get_tree().create_timer(0.4).timeout
	stopMoving.emit(true)
	minigameProg = false
	stopSfx("lockpickingSFX", btn)
	awaitSfx("UnlockSFX", btn)
	if is_instance_valid(pickGame):
		pickGame.queue_free()
	locked = false
	
func climb() -> void:
	#print("climbed")
	var tempPlayer = player
	if tempPlayer == null:
		return
	var enteringHouse: bool = !tempPlayer.inside
	tempPlayer.climbing = true
	stopMoving.emit(false)
	tempPlayer.set_collision_mask_value(tempPlayer.curFloor, false)
	
	var distA = tempPlayer.global_position.distance_to(pointA.global_position)
	var distB = tempPlayer.global_position.distance_to(pointB.global_position)
	var dest: Vector2
	
	if distA < distB:
		dest = pointB.global_position
	else:
		dest = pointA.global_position
	#inside = !inside
	#print(inside)
	var tween = create_tween()
	tween.tween_property(tempPlayer, "global_position", dest, 0.7).set_trans(Tween.TRANS_SINE)
	
	await tween.finished
	tempPlayer.inside = enteringHouse
	tempPlayer.set_collision_mask_value(tempPlayer.curFloor, true)
	stopMoving.emit(true)
	if enteringHouse:
		GlobalSignal.updRoofVisibility.emit(tempPlayer.curFloor)
	else:
		GlobalSignal.updRoofVisibility.emit(0)
	await get_tree().physics_frame
	await get_tree().physics_frame
	tempPlayer.climbing = false

func cancelMinigame() -> void:
	if isLockPick:
		stopSfx("lockpickingSFX", btnGlobal)
		isLockPick = false
	if isDrilling:
		curPosDrill = drillGame.getDrillPos()
		isDrilling = false
	closeMinigame()

func checkTileData():
	super()
	curTileMap = get_parent() as TileMapLayer
	if curTileMap:
		var local_pos = curTileMap.to_local(global_position)
		map_pos = curTileMap.local_to_map(local_pos)
		
		var data = curTileMap.get_cell_tile_data(map_pos)
		
		curtain = data.get_custom_data("curtain")

func _on_drill_success() -> void:
	await get_tree().create_timer(0.55).timeout
	stopMoving.emit(true)
	minigameProg = false
	locked = false
	if is_instance_valid(drillGame):
		drillGame.queue_free()
	isDrilling = false
