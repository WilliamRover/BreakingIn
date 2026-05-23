class_name Pin extends RigidBody2D

@onready var spring: Sprite2D = $"../Spring"

var startX: float
var initDist: float
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	startX = global_position.x
	initDist = global_position.y - spring.global_position.y
	
func _process(_delta: float) -> void:
	var curDist = global_position.y - spring.global_position.y
	spring.scale.y = clamp(curDist / initDist, 0.1, 1)

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	state.linear_velocity.x = 0
	var newTransform = state.transform
	newTransform.origin.x = startX
	state.transform = newTransform
