class_name Player extends CharacterBody2D


const SPEED = 300
#const JUMP_VELOCITY = -400.0
var movable: bool = true
@onready var notif: Label = $CanvasLayerNotif/Notification
@onready var notifAnchor: Marker2D = $NotifAnchor
@onready var flashlight: PointLight2D = $FlashLight
@onready var flashLight2: PointLight2D = $FlashLight/PointLight2D2
@onready var visionCone: PointLight2D = $VisionCone
@onready var visionCone2: PointLight2D = $VisionCone/VisionCone2
@export var visionLayer:= 10

var objInCones: Array[Node2D] = []
@onready var visionRay: RayCast2D = $VisionRay
@onready var walkSfx: AudioStreamPlayer = $Walk
@onready var animSprite: AnimatedSprite2D = $AnimatedSprite2D

@export var startingFloor := 1
var curFloor := startingFloor

@export var inside: bool = false
@export var onStair: bool = false
var climbing: bool = false
func _ready() -> void:
	flashlight.visible = false
	notif.visible = false
	updateLightningFloor(startingFloor)
func _physics_process(_delta: float) -> void:
	var screen_pos = notifAnchor.get_global_transform_with_canvas().origin
	#notif.position = originalNotifPosition
	notif.global_position = screen_pos - (notif.size / 2.0)
	if Input.is_action_just_pressed("ILLUMINATOR MENU - T"):
		flashlight.visible = !flashlight.visible
	var direction := Input.get_vector("PLAYER - A", "PLAYER - D", "PLAYER - W", "PLAYER - S")
	if movable:
		#print(direction)
		if direction:
			velocity = direction * SPEED
			flashlight.rotation = direction.angle()
			visionCone.rotation = direction.angle()
			if not walkSfx.playing:
				walkSfx.play()
			# D
			if direction.x == 1:
				animSprite.play("Idle - D")
				animSprite.flip_h = false
			# A
			if direction.x == -1:
				animSprite.play("Idle - D")
				animSprite.flip_h = true
			# SD
			if direction.y > 0 && direction.x > 0:
				animSprite.play("Idle - SD")
				animSprite.flip_h = false
			# WD
			if direction.y < 0 && direction.x > 0:
				animSprite.play("Idle - WD")
				animSprite.flip_h = false
			# SA
			if direction.y > 0 && direction.x < 0:
				animSprite.play("Idle - SD")
				animSprite.flip_h = true
			# WA
			if direction.y < 0 && direction.x < 0:
				animSprite.play("Idle - WD")
				animSprite.flip_h = true
			# W
			if direction.y == -1:
				animSprite.play("Idle - W")
				animSprite.flip_h = false
			# S
			if direction.y == 1:
				animSprite.play("Idle - S")
				animSprite.flip_h = false
		else:
			velocity = velocity.move_toward(Vector2.ZERO, SPEED)
			if walkSfx.playing:
				walkSfx.stop()
	else:
		velocity = Vector2.ZERO
	if Input.is_action_pressed("RMOUSE"):
		flashlight.look_at(get_global_mouse_position())
		visionCone.look_at(get_global_mouse_position())
		velocity *= 0.45
		walkSfx.pitch_scale = 0.6 
	else:
		walkSfx.pitch_scale = 1.0
	
	if Input.is_action_pressed("RUN - LSHIFT"):
		velocity *= 2
		walkSfx.pitch_scale = 1.5
	
	
	move_and_slide()
	
	for obj in objInCones:
		visionRay.target_position = visionRay.to_local(obj.global_position + Vector2(0, -15)) * 1.05
		visionRay.force_raycast_update()
		
		if visionRay.is_colliding() && visionRay.get_collider() == obj:
			pass
		#print(obj.name + " " + str(visionRay.get_collider()))
func _on_window_stop_moving(canMove: bool) -> void:
	movable = canMove
	
func _on_label_set_text(text: String) -> void:
	notif.text = text
	notif.visible = true
	await get_tree().create_timer(2.5).timeout
	notif.visible = false
	


func _on_vision_detect_body_entered(body: Node2D) -> void:
	if body.is_in_group("Obj"):
		objInCones.append(body)


func _on_vision_detect_body_exited(body: Node2D) -> void:
	if body.is_in_group("Obj"):
		objInCones.erase(body)

func updateLightningFloor(floorLayer: int) -> void:
	z_index = floorLayer - 1
	#print(z_index)
	curFloor = floorLayer
	#print(curFloor)
	var floorBitmask:= 1 << (floorLayer - 1)
	var wallBitmask := 1 << ((floorLayer - 1) + 10)
	var visionBitmask := 1 << ((visionLayer - 1) + 5)
	var combinedMask := floorBitmask | visionBitmask
	
	if visionCone:
		visionCone.range_item_cull_mask = combinedMask
		visionCone.shadow_item_cull_mask = combinedMask
	if flashlight:
		flashlight.range_item_cull_mask = combinedMask
		flashlight.shadow_item_cull_mask = combinedMask
		
	var shineMask := wallBitmask
	if visionCone2:
		visionCone2.range_item_cull_mask = shineMask
	if flashLight2:
		flashLight2.range_item_cull_mask = shineMask
	light_mask = floorBitmask
	animSprite.light_mask = wallBitmask
