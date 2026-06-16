class_name NearBookShelf extends Near

@export var findFilesScene: PackedScene = preload("res://Scenes/Minigame/FindFiles/findFiles.tscn")
var findFileGame: Node
var isSearching: bool = false
var assignedIntel: String = ""

func _ready() -> void:
	super()

func interactAction() -> void:
	pass
	
func execute_action(action_name: String, button: Button) -> void:
	stopMoving.emit(false)

	match action_name:
		"Search":
			stopMoving.emit(false)
			awaitSfx("SearchSfx", button)
			isSearching = true
			findFileGame = innitMinigame(findFilesScene)
			findFileGame.provideIntel.emit(assignedIntel)
			minigameProg = true
			await findFileGame.tree_exited
			#if locked:
				#awaitSfx("SafeLock", button)
			#else:
				#open = !open
				#if open:
					#if filled:
						#update_tile_visual(open_filled_safe_atlas, 0)
					#else:
						#update_tile_visual(open_empty_safe_atlas, 0)
					#awaitSfx("SafeOpen", button)
				#else:
					#update_tile_visual(close_safe_atlas, 0)
					#awaitSfx("SafeClose", button)
			
	stopMoving.emit(true)
	enableFloatingOption()

func checkTileData():
	pass

func get_available_actions() -> Array[String]:
	var actions: Array[String] = []
	actions.append("Search")
	return actions

func cancelMinigame() -> void:
	if isSearching:
		isSearching = false
	closeMinigame()
	
func assignIntel(intel: String) -> void:
	assignedIntel = intel
