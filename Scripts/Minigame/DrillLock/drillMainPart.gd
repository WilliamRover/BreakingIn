extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var move: bool = true

func _ready() -> void:
	$DrillStart.finished.connect(drillSfxStart)

func _physics_process(delta: float) -> void:
	if !move:
		velocity = Vector2(0, 0)
		move_and_slide()
		return
	if Input.is_action_pressed("RMOUSE"):
		velocity = Vector2(0, -8) * delta * SPEED
		#print(position)
	else:
		velocity = Vector2(0, 0)
	
	if Input.is_action_just_pressed("RMOUSE"):
		$DrillStart.play()
	if Input.is_action_just_released("RMOUSE"):
		$DrillStart.stop()
		$DrillLoop.stop()
		$DrillEnd.play()
	move_and_slide()

func drillSfxStart() -> void:
	if Input.is_action_pressed("RMOUSE"):
		$DrillLoop.play()
