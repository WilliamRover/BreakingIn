extends Area2D

static var active_window: Area2D = null
@onready var uiAnchor: Marker2D = $UIAnchor
var screen_pos
@onready var label: Label = $CanvasLayer/Label
@onready var floatingOption = $CanvasLayer/FloatingOption
var player: CharacterBody2D = null
var holdTime: float = 0
var floatingOptionLock: bool = false

var open: bool
var isWindow: bool
var isDoor: bool
var isBroken: bool
var locked: bool

var curTileMap: TileMapLayer
var map_pos: Vector2i
var btnGlobal: Button
var wallFade: bool = false
# PointA PointB
@onready var pointA: Marker2D = $PointA
@onready var pointB: Marker2D = $PointB
# ID 0
@export var closeDoorAtlas: Vector2i = Vector2i(1, 0)
@export var openDoorAtlas: Vector2i = Vector2i(1, 1)
@export var closeWinAtlas: Vector2i = Vector2i(0, 1)
@export var openWinAtlas: Vector2i = Vector2i(0, 2)
@export var brokenWinAtlas: Vector2i = Vector2i(0, 3)
# ID 1
@export var lockedDoorAtlas: Vector2i = Vector2i(1, 0)
@export var lockedWinAtlas: Vector2i = Vector2i(0, 1)
signal clearArea2D()
signal stopMoving(move: bool)
signal showNotif(text: String)

# Minigame
@export var lockpickMinigame: PackedScene = preload("res://Scenes/Minigame/Lockpick/lock_pick.tscn")
var pickGame: Node
var lockpingProg: bool = false
var lockSeed := -1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.hide()
	floatingOption.hide()
	checkTileData()

func _process(delta: float) -> void:
	if player && active_window == self && !lockpingProg:
		screen_pos = player.get_global_transform_with_canvas().origin
		label.position = screen_pos
		if Input.is_action_pressed("OPTION MENU - HOLD E"):
			holdTime += delta
			if holdTime >= 0.6:
				if floatingOptionLock == false:
					enableFloatingOption()
		elif Input.is_action_just_released("OPTION MENU - HOLD E"):
			if isWindow && isBroken:
				showNotif.emit("Nah window is broken")
				return
			if holdTime < 0.6 and floatingOptionLock == false:
				_on_floating_option_btn_pressed("Open_Close")
		
	if Input.is_action_just_pressed("CANCEL - Q") && lockpingProg:
		stopSfx("lockpickingSFX", btnGlobal)
		pickGame.queue_free()
		lockpingProg = false
		stopMoving.emit(true)
func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player = body
		active_window = self
		label.show()
		if !stopMoving.is_connected(player._on_window_stop_moving):
			stopMoving.connect(player._on_window_stop_moving)
		if !showNotif.is_connected(player._on_label_set_text):
			showNotif.connect(player._on_label_set_text)

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		label.hide()
		if active_window == self:
			active_window = null
		if floatingOptionLock:
			_on_floating_option_btn_pressed()
		if stopMoving.is_connected(player._on_window_stop_moving):
			stopMoving.disconnect(player._on_window_stop_moving)
		if showNotif.is_connected(player._on_label_set_text):
			showNotif.disconnect(player._on_label_set_text)

func enableFloatingOption():
	label.hide()
	if isDoor:
		floatingOption.get_node("Climb").visible = false
	if !open:
		floatingOption.get_node("Climb").visible = false
	elif open && isWindow:
		floatingOption.get_node("Climb").visible = true
	if isBroken && isWindow:
		floatingOption.get_node("Open_Close").visible = false
	if isBroken || !locked:
		floatingOption.get_node("Picklock").visible = false
		floatingOption.get_node("Kick_Break").visible = false
		floatingOption.get_node("Pry").visible = false
	else:
		floatingOption.get_node("Picklock").visible = true
		floatingOption.get_node("Kick_Break").visible = true
		floatingOption.get_node("Pry").visible = true
	floatingOption.pivot_offset = floatingOption.size / 2
	floatingOption.scale = Vector2.ZERO # Start tiny
	floatingOption.position = screen_pos
	floatingOption.show()
	floatingOptionLock = true
	clearArea2D.emit()
	var tween = create_tween()
	tween.tween_property(floatingOption, "scale", Vector2.ONE, 0.2)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)

func _on_floating_option_btn_pressed(btnName: String = "") -> void:
	#print(btnName)
	if btnName != "":
		btnGlobal = floatingOption.get_node(btnName)
		stopMoving.emit(false)
		match btnName:
			"Open_Close":
				if !locked:
					if !open:
						if isWindow:
							awaitSfx("OpenWinSFX", btnGlobal)
							update_tile_visual(openWinAtlas, 0)
						else:
							awaitSfx("OpenDoorSFX", btnGlobal)
							update_tile_visual(openDoorAtlas, 0)
					else:
						if isWindow:
							awaitSfx("CloseWinSFX", btnGlobal)
							update_tile_visual(closeWinAtlas, 0)
						else:
							awaitSfx("CloseDoorSFX", btnGlobal)
							update_tile_visual(closeDoorAtlas, 0)
					open = !open
				else:
					awaitSfx("LockedSFX", btnGlobal)
					showNotif.emit("Seems like it's locked")
			"Climb":
				climb()
				awaitSfx("ClimbThroughSFX", btnGlobal)
			"Picklock":
				stopMoving.emit(false)
				pickGame = lockpickMinigame.instantiate()
				$CanvasLayer.add_child(pickGame)
				lockpingProg = true
				if lockSeed == -1:
					lockSeed = pickGame.generateNewLock()
				else:
					pickGame.retry_saved_lock(lockSeed)
				pickGame.allPinPushed.connect(_on_finished_lockpick.bind(btnGlobal))
				awaitSfx("lockpickingSFX", btnGlobal)
				await pickGame.tree_exited
				
			"Kick_Break":
				if isDoor:
					awaitSfx("KickSFX", btnGlobal)
					update_tile_visual(openDoorAtlas, 0)
				else:
					awaitSfx("SmashSFX", btnGlobal)
					update_tile_visual(brokenWinAtlas, 0)
				isBroken = true
				locked = false
				open = true
			"Pry":
				awaitSfx("PrySFX", btnGlobal)
				if isDoor:
					update_tile_visual(openDoorAtlas, 0)
				else:
					update_tile_visual(openWinAtlas, 0)
				open = true
				locked = false
	stopMoving.emit(true)
	enableFloatingOption()
	floatingOptionLock = false
	floatingOption.hide()
	holdTime = 0

func checkTileData():
	curTileMap = get_parent() as TileMapLayer
	if curTileMap:
		var local_pos = curTileMap.to_local(global_position)
		map_pos = curTileMap.local_to_map(local_pos)
		
		var data = curTileMap.get_cell_tile_data(map_pos)
		
		open = data.get_custom_data("open")
		isBroken = data.get_custom_data("isBroken")
		isDoor = data.get_custom_data("isDoor")
		isWindow = data.get_custom_data("isWindow")
		locked = data.get_custom_data("locked")

func update_tile_visual(target_coord: Vector2i, id: int):
	var current_alt_id = curTileMap.get_cell_alternative_tile(map_pos)
	curTileMap.set_cell(map_pos, id, target_coord, current_alt_id)
	

func awaitSfx(sfxName: String, btn: Button):
	btn.get_node(sfxName).play()

func stopSfx(sfxName: String, btn: Button):
	btn.get_node(sfxName).stop()

func _on_finished_lockpick(btn: Button) -> void:
	await get_tree().create_timer(0.4).timeout
	stopSfx("lockpickingSFX", btn)
	awaitSfx("UnlockSFX", btn)
	locked = false
	pickGame.queue_free()
	lockpingProg = false
	stopMoving.emit(true)

func climb() -> void:
	stopMoving.emit(false)
	player.set_collision_mask_value(1, false)
	
	var distA = player.global_position.distance_to(pointA.global_position)
	var distB = player.global_position.distance_to(pointB.global_position)
	
	var dest: Vector2
	if distA < distB:
		dest = pointB.global_position
	else:
		dest = pointA.global_position
		
	var tween = create_tween()
	tween.tween_property(player, "global_position", dest, 0.7).set_trans(Tween.TRANS_SINE)
	
	await tween.finished
	player.set_collision_mask_value(1, true)
	stopMoving.emit(true)

#func fadeWallBehind(fade: bool) -> void:
	#wallFade = fade
	#var alpha: float
	#if fade:
		#alpha = 0.4
	#else:
		#alpha = 1
	#var tween = create_tween()
	#tween.tween_property(curTileMap, "modulate:a", alpha, 0.3)
