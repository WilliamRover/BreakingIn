class_name PoliceCar extends AnimatableBody2D

@onready var animLights: AnimationPlayer = $AnimationPlayer
@onready var lightArr: Array[PointLight2D] = [
	$FrontBulb,
	$FrontBulb/FrontBulbRay3,
	$FrontBulb/FrontBulbRay4,
	$TopLight,
	$SurroundLight
]

@onready var headLight: PointLight2D = $FrontBulb
@onready var siren: AudioStreamPlayer2D = $SirenWail
@export var headlightsOn: bool = true
@export var curFloor: int = 1
#@export var flip: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	#if flip:
		#scale.x = -abs(scale.x)
	#spawnPolice()
	if headlightsOn:
		headLight.visible = true
	else:
		headLight.visible = false

func spawnPolice() -> void:
	visible = true
	siren.play()
	animLights.active = true
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
