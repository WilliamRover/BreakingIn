class_name StateDisabled extends State

var security: Security

func _ready() -> void:
	await owner.ready
	security = owner as Security

func _on_enter() -> void:
	security.velocity = Vector2.ZERO
	
	security.visionArea.set_deferred("monitoring", false)
	security.visionRay.enabled = false
	security.animSprite.rotation_degrees = 90
	security.animSprite.stop()

func _on_physic_process(_delta: float) -> void:
	pass
