class_name Security extends CharacterBody2D

const SPEED = 100
@onready var walkSfx: AudioStreamPlayer2D = $Walk
@onready var surprisedSfx: AudioStreamPlayer2D = $Surprised
@onready var animSprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var visionArea: Area2D = $VisionArea
@onready var visionRay: RayCast2D = $VisionRay

@export var curFloor := 1

@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var detectionBar: ProgressBar = $DetectionBar
@onready var notifLabel: Label = $Notif
@export var dest: Array[Vector2] = []:
	set(value):
		dest = value
		if is_node_ready() && nav && dest.size() > 0:
			curNavIdx = clampi(curNavIdx, 0, dest.size() - 1)
			nav.target_position = dest[curNavIdx]
		

var curNavIdx := 0
var objInSight: Node2D = null

func _ready() -> void:
	curNavIdx = 0
	nav.target_position = dest[curNavIdx]
	#visionRay.collision_mask = 1 << ((curFloor - 1) + 10)

func updateAnimation(dir: Vector2) -> void:
	var x = round(dir.x)
	var y = round(dir.y)
	#print("anim running")
	#print_stack()
	visionArea.rotation = dir.angle()
	# D
	if x == 1 and y == 0:
		animSprite.play("Idle - D")
		animSprite.flip_h = false
	# A
	elif x == -1 and y == 0:
		animSprite.play("Idle - D")
		animSprite.flip_h = true
	# SD
	elif y > 0 and x > 0:
		animSprite.play("Idle - SD")
		animSprite.flip_h = false
	# WD
	elif y < 0 and x > 0:
		animSprite.play("Idle - WD")
		animSprite.flip_h = false
	# SA
	elif y > 0 and x < 0:
		animSprite.play("Idle - SD")
		animSprite.flip_h = true
	# WA
	elif y < 0 and x < 0:
		animSprite.play("Idle - WD")
		animSprite.flip_h = true
	# W
	elif y == -1 and x == 0:
		animSprite.play("Idle - W")
		animSprite.flip_h = false
	# S
	elif y == 1 and x == 0:
		animSprite.play("Idle - S")
		animSprite.flip_h = false


func _on_vision_area_body_entered(body: Node2D) -> void:
	if body is Player:
		objInSight = body


func _on_vision_area_body_exited(body: Node2D) -> void:
	if body == objInSight:
		if body.curFloor == self.curFloor:
			objInSight = null
		
func seePlayer() -> bool:
	#print("obj in sight" + str(objInSight))
	if objInSight == null || objInSight.curFloor != self.curFloor :
		return false
		
	visionRay.target_position = to_local(objInSight.global_position)
	visionRay.clear_exceptions()
	while true:
		visionRay.force_raycast_update()
		
		if visionRay.is_colliding():
			var collider = visionRay.get_collider()
			#print(collider)
			if collider == objInSight:
				return true
			elif collider is Furniture:
				var hitRid = visionRay.get_collider_rid()
				visionRay.add_exception_rid(hitRid)
				continue
			else:
				return false
	
		else: 
			return false
	return false
