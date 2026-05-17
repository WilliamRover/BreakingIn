class_name Player extends CharacterBody2D


const SPEED = 300
#const JUMP_VELOCITY = -400.0
var movable: bool = true
@onready var notif: Label = $CanvasLayerNotif/Notification
@onready var notifAnchor: Marker2D = $NotifAnchor
@onready var flashlight: PointLight2D = $FlashLight
@onready var visionCone = [
	$VisionCone,
	$VisionCone/ObjectCone,
	$VisionCone/VisionCone2,
	$VisionCone/PointLight2D3
]
@onready var walkSfx: AudioStreamPlayer = $Walk
@onready var animSprite: AnimatedSprite2D = $AnimatedSprite2D
func _physics_process(delta: float) -> void:
	var screen_pos = notifAnchor.get_global_transform_with_canvas().origin
	notif.global_position = screen_pos - (notif.size / 2.0)
	if Input.is_action_just_pressed("ILLUMINATOR MENU - T"):
		flashlight.visible = !flashlight.visible
	var direction := Input.get_vector("PLAYER - A", "PLAYER - D", "PLAYER - W", "PLAYER - S")
	if movable:
		#print(direction)
		if direction:
			velocity = direction * SPEED
			flashlight.rotation = direction.angle()
			visionCone[0].rotation = direction.angle()
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
		visionCone[0].look_at(get_global_mouse_position())
		velocity *= 0.45
		walkSfx.pitch_scale *= 0.6 
	else:
		walkSfx.pitch_scale = 1.0
	
	if Input.is_action_pressed("RUN - LSHIFT"):
		velocity *= 2
		walkSfx.pitch_scale *= 1.5
	
	
	move_and_slide()

func _on_window_stop_moving(canMove: bool) -> void:
	movable = canMove
	
func _on_label_set_text(text: String) -> void:
	notif.text = text
	notif.visible = true
	await get_tree().create_timer(2.5).timeout
	notif.visible = false
func _on_ready() -> void:
	flashlight.visible = false
	notif.visible = false
	pass # Replace with function body.
