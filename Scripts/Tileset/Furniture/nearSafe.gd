class_name NearSafe extends Near

# ID 0
@export var close_safe_atlas := Vector2i(0,3)
@export var open_filled_safe_atlas := Vector2i(0,4)
@export var open_empty_safe_atlas := Vector2i(0,5)
var filled: bool
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
	if locked:
		actions.append("Open")
		actions.append("Crack")
	if open && filled:
		actions.append("Grab")
	return actions
