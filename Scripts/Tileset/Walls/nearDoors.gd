class_name NearDoor extends Near

# ID 0
@export var close_door_atlas := Vector2i(1, 0)
@export var open_door_atlas := Vector2i(1, 1)

@export var lockpickMinigame: PackedScene = preload("res://Scenes/Minigame/Lockpick/lock_pick.tscn")
var pickGame: Node
var lock_seed: int = -1
# Overide thingy
func get_available_actions() -> Array[String]:
	var actions: Array[String] = []
	actions.append("Open_Close")
	if locked:
		actions.append("Picklock")
		actions.append("Pry")
		actions.append("Kick_Break")
			
	return actions

func interactAction() -> void:
	_on_action_button_pressed("Open_Close", floatingOption.get_node("Open_Close"))

func execute_action(action_name: String, button: Button) -> void:
	match action_name:
		"Open_Close":
			if locked:
				awaitSfx("LockedSFX", button)
				showNotif.emit("Seems like it's locked")
			else:
				open = !open
				if open:
					update_tile_visual(open_door_atlas, 0)
					awaitSfx("OpenDoorSFX", button)
				else:
					update_tile_visual(close_door_atlas, 0)
					awaitSfx("CloseDoorSFX", button)
		"Picklock":
			stopMoving.emit(false)
			minigameProg = true
			pickGame = innitMinigame(lockpickMinigame)
			awaitSfx("lockpickingSFX", button)
			
			if lock_seed == -1:
				lock_seed = pickGame.generateNewLock()
			else:
				pickGame.retry_saved_lock(lock_seed)
				
			pickGame.allPinPushed.connect(_on_finished_lockpick.bind(button))
			await pickGame.tree_exited
		"Kick_Break":
			awaitSfx("KickSFX", button)
			update_tile_visual(open_door_atlas, 0)
			locked = false
			open = true
		"Pry":
			awaitSfx("PrySFX", button)
			update_tile_visual(open_door_atlas, 0)
			locked = false
			open = true
	stopMoving.emit(true)
	enableFloatingOption()

func _on_finished_lockpick(btn: Button) -> void:
	await get_tree().create_timer(0.4).timeout
	stopMoving.emit(true)
	minigameProg = false
	stopSfx("lockpickingSFX", btn)
	awaitSfx("UnlockSFX", btn)
	pickGame.queue_free()
	locked = false
