class_name NearGarage extends Near

var garageId: String = ""
# ID 2
@export var close_door_atlas := Vector2i(0, 0)
@export var open_door_atlas := Vector2i(0, 1)
func _ready() -> void:
	super()
	GlobalSignal.openGarage.connect(_on_global_garage_toggle)

func get_available_actions() -> Array[String]:
	return ["Open_Close_Garage"]
func interactAction() -> void:
	_on_action_button_pressed("Open_Close_Garage", floatingOption.get_node("Open_Close_Garage"))

func execute_action(action_name: String, button: Button) -> void:
	match action_name:
		"Open_Close_Garage":
			awaitSfx("LockGarageSFX", button)
			showNotif.emit("Seems like I have to trigger it somewhere else")
	stopMoving.emit(true)
	enableFloatingOption()

func _on_global_garage_toggle(broadcasted_id: String) -> void:
	if broadcasted_id == garageId:
		openGarage()

func openGarage() -> void:
	open = !open
	if open:
		#print("opened")
		update_tile_visual(open_door_atlas, 2)
		awaitSfx("OpenGarageSFX", floatingOption.get_node_or_null("Open_Close_Garage"))
	else:
		#print("closed")
		update_tile_visual(close_door_atlas, 2)
		awaitSfx("CloseGarageSFX", floatingOption.get_node_or_null("Open_Close_Garage"))
