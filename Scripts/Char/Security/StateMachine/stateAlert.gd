class_name StateAlert extends State

var security: Security
var alertTime: float = 0
var callPoliceTime: float = 2

func _ready() -> void:
	await owner.ready
	security = owner as Security
	
func _on_enter() -> void:
	alertTime = 0
	#security.velocity = Vector2.ZERO
	security.detectionBar.visible = false
	security.notifLabel.visible = true
	security.notifLabel.add_theme_color_override("font_color", Color.RED)
	security.notifLabel.add_theme_color_override("font_size", 26)
	security.notifLabel.position = Vector2(-8, -201)
	security.notifLabel.text = "!!"
	security.surprisedSfx.play()
	#print("alerted")
	
func _on_physic_process(_delta: float) -> void:
	alertTime += _delta
	if security.objInSight:
			var dirToObj = (security.objInSight.global_position - security.global_position).normalized()
			security.updateAnimation(dirToObj)
	
	if alertTime >= callPoliceTime:
		security.notifLabel.visible = false
		transitionState.emit(self, "StateCallPolice")
