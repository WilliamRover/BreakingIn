class_name PoliceCar extends AnimatableBody2D

@onready var animLights: AnimationPlayer = $AnimationPlayer
@onready var lightArr: Array[PointLight2D] = [
	$FrontBulb,
	$FrontBulb/FrontBulbRay3,
	$FrontBulb/FrontBulbRay4,
	$TopLight,
	$SurroundLight
]
@onready var siren: AudioStreamPlayer2D = $SirenWail
@export var curFloor: int = 1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	#spawnPolice()

func spawnPolice() -> void:
	visible = true
	siren.play()
	await get_tree().physics_frame
	var floorBitmask := 1 << ((curFloor - 1) + 10)
	#print(floorBitmask)
	for light in lightArr:
		if light == $FrontBulb/FrontBulbRay3 || light == $FrontBulb/FrontBulbRay4:
			var curFloorMask = 1 << (curFloor - 1)
			light.range_item_cull_mask = floorBitmask | curFloorMask
			continue
		light.range_item_cull_mask = floorBitmask
		#print(light)
		#print(floorBitmask)
	light_mask = floorBitmask
