class_name Near extends Area2D

signal clearArea2D()
signal stopMoving(move: bool)
signal showNotif(text: String)

static var active_window: Area2D = null
@onready var uiAnchor: Marker2D = $UIAnchor
var screen_pos: Vector2
@onready var label: Label = $CanvasLayer/Label
@onready var floatingOption = $CanvasLayer/FloatingOption
var player: CharacterBody2D = null
var holdTime: float = 0
var floatingOptionLock: bool = false

var open: bool
var isBroken: bool
var locked: bool

var curTileMap: TileMapLayer
var map_pos: Vector2i

# Lockpick Minigame
var minigame: Node = null
var minigameProg: bool = false

var btnGlobal: Button
func _ready() -> void:
	label.hide()
	floatingOption.hide()
	checkTileData()
func _process(delta: float) -> void:
	if player && active_window == self && !minigameProg:
		screen_pos = player.get_global_transform_with_canvas().origin
		label.position = screen_pos
		if Input.is_action_pressed("OPTION MENU - HOLD E"):
			holdTime += delta
			if holdTime >= 0.6 && !floatingOptionLock:
				enableFloatingOption()
		elif Input.is_action_just_released("OPTION MENU - HOLD E"):
			if holdTime < 0.6 && !floatingOptionLock:
				interactAction()
		
	if Input.is_action_just_pressed("CANCEL - Q") && minigameProg:
		cancelMinigame()
		stopMoving.emit(true)
func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		#print("Floor:" + str(get_parent().get_parent().targetPhysLayer))
		#print("Player:" + str(body.curFloor))
		if get_parent().get_parent().targetPhysLayer != body.curFloor:
			return
		player = body
		active_window = self
		label.show()
		_connect_player_signals()

func _on_body_exited(body: Node2D) -> void:
	if body == player:
		label.hide()
		if active_window == self:
			active_window = null
		if floatingOptionLock:
			_close_floating_options()
		_disconnect_player_signals()
		player = null


# ABSTRACT FUNC. OVERRIDE TS
func get_available_actions() -> Array[String]:
	return [] # ex: [Pry, Open/close, ...]
func execute_action(_action_name: String, _button: Button) -> void:
	#if btnName != "":
		#btnGlobal = floatingOption.get_node(btnName)
		#stopMoving.emit(false)
		#match btnName:
			#"Open_Close":
				#if !locked:
					#if !open:
						#if isWindow:
							#awaitSfx("OpenWinSFX", btnGlobal)
							#update_tile_visual(openWinAtlas, 0)
						#else:
							#awaitSfx("OpenDoorSFX", btnGlobal)
							#update_tile_visual(openDoorAtlas, 0)
					#else:
						#if isWindow:
							#awaitSfx("CloseWinSFX", btnGlobal)
							#update_tile_visual(closeWinAtlas, 0)
						#else:
							#awaitSfx("CloseDoorSFX", btnGlobal)
							#update_tile_visual(closeDoorAtlas, 0)
					#open = !open
				#else:
					#awaitSfx("LockedSFX", btnGlobal)
					#showNotif.emit("Seems like it's locked")
			#"Climb":
				#climb()
				#awaitSfx("ClimbThroughSFX", btnGlobal)
			#"Picklock":
				#stopMoving.emit(false)
				#pickGame = lockpickMinigame.instantiate()
				#$CanvasLayer.add_child(pickGame)
				#lockpingProg = true
				#if lockSeed == -1:
					#lockSeed = pickGame.generateNewLock()
				#else:
					#pickGame.retry_saved_lock(lockSeed)
				#pickGame.allPinPushed.connect(_on_finished_lockpick.bind(btnGlobal))
				#awaitSfx("lockpickingSFX", btnGlobal)
				#await pickGame.tree_exited
				#
			#"Kick_Break":
				#if isDoor:
					#awaitSfx("KickSFX", btnGlobal)
					#update_tile_visual(openDoorAtlas, 0)
				#else:
					#awaitSfx("SmashSFX", btnGlobal)
					#update_tile_visual(brokenWinAtlas, 0)
				#isBroken = true
				#locked = false
				#open = true
			#"Pry":
				#awaitSfx("PrySFX", btnGlobal)
				#if isDoor:
					#update_tile_visual(openDoorAtlas, 0)
				#else:
					#update_tile_visual(openWinAtlas, 0)
				#open = true
				#locked = false
	pass 
func interactAction() -> void:
	pass
	
	
# MINIGAME
func innitMinigame(scene: PackedScene) -> Node:
	stopMoving.emit(false)
	minigameProg = true
	
	minigame = scene.instantiate()
	$CanvasLayer.add_child(minigame)
	
	return minigame

func closeMinigame() -> void:
	if minigame:
		minigame.queue_free()
	
	minigameProg = false
	#stopMoving.emit(true)

func cancelMinigame() -> void:
	#some penalty here idk
	closeMinigame()


# UTIL
func enableFloatingOption():
	label.hide()
	for elem in floatingOption.get_children():
		if elem is Button:
			elem.hide()
			if elem.pressed.is_connected(_on_action_button_pressed):
				elem.pressed.disconnect(_on_action_button_pressed)
	var actions: Array[String] = get_available_actions()
	for action in actions:
		var btn = floatingOption.get_node_or_null(action)
		if btn and (btn is Button):
			btn.show()
			btn.pressed.connect(_on_action_button_pressed.bind(action, btn))
	#if isDoor:
		#floatingOption.get_node("Climb").visible = false
	#if !open:
		#floatingOption.get_node("Climb").visible = false
	#elif open && isWindow:
		#floatingOption.get_node("Climb").visible = true
	#if isBroken && isWindow:
		#floatingOption.get_node("Open_Close").visible = false
	#if isBroken || !locked:
		#floatingOption.get_node("Picklock").visible = false
		#floatingOption.get_node("Kick_Break").visible = false
		#floatingOption.get_node("Pry").visible = false
	#else:
		#floatingOption.get_node("Picklock").visible = true
		#floatingOption.get_node("Kick_Break").visible = true
		#floatingOption.get_node("Pry").visible = true
	floatingOption.pivot_offset = floatingOption.size / 2
	floatingOption.scale = Vector2.ZERO
	floatingOption.position = screen_pos
	floatingOption.show()
	floatingOptionLock = true
	clearArea2D.emit()
	var tween = create_tween()
	tween.tween_property(floatingOption, "scale", Vector2.ONE, 0.2)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)

func _on_action_button_pressed(action_name: String, button: Button) -> void:
	#stopMoving.emit(false)q
	
	# Pass execution to the specific subclass
	btnGlobal = button
	execute_action(action_name, button)
	
	#stopMoving.emit(true)
	enableFloatingOption()
	floatingOptionLock = false
	floatingOption.hide()
	holdTime = 0

func _close_floating_options() -> void:
	floatingOption.hide()
	floatingOptionLock = false
	holdTime = 0.0

func checkTileData():
	curTileMap = get_parent() as TileMapLayer
	if curTileMap:
		var local_pos = curTileMap.to_local(global_position)
		map_pos = curTileMap.local_to_map(local_pos)
		
		var data = curTileMap.get_cell_tile_data(map_pos)
		
		open = data.get_custom_data("open")
		isBroken = data.get_custom_data("isBroken")
		locked = data.get_custom_data("locked")

func update_tile_visual(target_coord: Vector2i, id: int):
	var current_alt_id = curTileMap.get_cell_alternative_tile(map_pos)
	curTileMap.set_cell(map_pos, id, target_coord, current_alt_id)
	
func awaitSfx(sfxName: String, btn: Button):
	btn.get_node(sfxName).play()

func stopSfx(sfxName: String, btn: Button):
	btn.get_node(sfxName).stop()
	
func _connect_player_signals() -> void:
	if !stopMoving.is_connected(player._on_window_stop_moving):
		stopMoving.connect(player._on_window_stop_moving)
	if !showNotif.is_connected(player._on_label_set_text):
		showNotif.connect(player._on_label_set_text)

func _disconnect_player_signals() -> void:
	if stopMoving.is_connected(player._on_window_stop_moving):
		stopMoving.disconnect(player._on_window_stop_moving)
	if showNotif.is_connected(player._on_label_set_text):
		showNotif.disconnect(player._on_label_set_text)
