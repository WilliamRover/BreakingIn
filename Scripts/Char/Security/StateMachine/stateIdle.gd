class_name StateIdle extends State

var waitTime: float = 0
var security: Security

func _ready() -> void:
	await owner.ready
	security = owner as Security
	
func _on_enter() -> void:
	waitTime = randf_range(12, 18)
	owner.velocity = Vector2.ZERO
	
func _on_process(_delta: float) -> void:
	waitTime -= _delta
	
	if waitTime <= 0:
		transitionState.emit(self, "StateRandomWalk")

func _on_physic_process(_delta: float) -> void:
	if security.seePlayer():
		transitionState.emit(self, "StateNoticing")
		return
