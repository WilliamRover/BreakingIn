class_name NearSafe extends Near

# ID 0
@export var close_safe_atlas := Vector2i(0,3)
@export var open_filled_safe_atlas := Vector2i(0,4)
@export var open_empty_safe_atlas := Vector2i(0,5)

@export var crackSafeMinigame: PackedScene = preload("res://Scenes/Minigame/SafeCracking/safe_cracking_minigame.tscn")
var filled: bool

var safeId: String = "safe"
var safeGame: Node
var isCracking: bool = false
signal safeCodeGenerated(safeId: String)
func _ready() -> void:
	super()
	safeId = "Safe" + str(randi() % 10000)
	#print(safeId)
	#generateSafeCode()

func interactAction() -> void:
	_on_action_button_pressed("Open_Close", floatingOption.get_node("Open_Close"))
	
func execute_action(action_name: String, button: Button) -> void:
	stopMoving.emit(false)
	match action_name:
		"Open_Close":
			if locked:
				awaitSfx("SafeLock", button)
				showNotif.emit("Seems like it's locked")
			else:
				open = !open
				if open:
					if filled:
						update_tile_visual(open_filled_safe_atlas, 0)
					else:
						update_tile_visual(open_empty_safe_atlas, 0)
					awaitSfx("SafeOpen", button)
				else:
					update_tile_visual(close_safe_atlas, 0)
					awaitSfx("SafeClose", button)
		"Crack":
			stopMoving.emit(false)
			isCracking = true
			safeGame = innitMinigame(crackSafeMinigame)
			safeGame.loadSafeData(safeId)
			minigameProg = true
			safeGame.safeCracked.connect(_on_safe_cracked)
			#drillGame.lockDrilled.connect(_on_drill_success)
			await safeGame.tree_exited
		"Grab":
			awaitSfx("GrabStuff", button)
			update_tile_visual(open_empty_safe_atlas, 0)
			filled = false
			
	stopMoving.emit(true)
	enableFloatingOption()

func checkTileData():
	curTileMap = get_parent() as TileMapLayer
	if curTileMap:
		var local_pos = curTileMap.to_local(global_position)
		map_pos = curTileMap.local_to_map(local_pos)
		
		var data = curTileMap.get_cell_tile_data(map_pos)
		
		open = data.get_custom_data("open")
		filled = data.get_custom_data("filled")
		locked = data.get_custom_data("locked")
	

func get_available_actions() -> Array[String]:
	var actions: Array[String] = []
	actions.append("Open_Close")
	if locked:
		actions.append("Crack")
	if open && filled:
		actions.append("Grab")
	return actions

func cancelMinigame() -> void:
	if isCracking:
		isCracking = false
	closeMinigame()
	
func _on_safe_cracked() -> void:
	await get_tree().create_timer(0.55).timeout
	stopMoving.emit(true)
	minigameProg = false
	locked = false
	if is_instance_valid(safeGame):
		safeGame.queue_free()
	isCracking = false

func generateSafeCode() -> void:
	var genCode: Array[String] = []
	randomize()
	for i in range(3):
		var ranNum = randi_range(0, 99)
		var strNum = "%02d" % ranNum
		genCode.append(strNum)
	safeCodeGenerated.emit(genCode)
	LevelStat.updLevelStat(safeId, "safeCode", genCode)
