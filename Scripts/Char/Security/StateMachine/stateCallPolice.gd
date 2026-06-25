class_name StateCallPolice extends State

var security: Security
var callTime: float = 0
var finishCallTime: float = 3.5
var called: bool = false
var policeCalled: bool = false

func _ready() -> void:
	await owner.ready
	security = owner as Security
	
func _on_enter() -> void:
	callTime = 0
	called = false
	security.notifLabel.visible = true
	security.notifLabel.add_theme_color_override("font_color", Color.WHITE)
	security.notifLabel.add_theme_color_override("font_size", 26)
	security.notifLabel.position = Vector2(-3, -227.0)
	security.notifLabel.text = """
	Hello, is this the police? Yeah someone
	   is trying to break in the premises
	"""
	
func _on_process(_delta: float) -> void:
	if called:
		return
	callTime += _delta
	if callTime >= finishCallTime && policeCalled == false:
		GlobalSignal.triggerCallPoliceSignal()
		policeCalled = true
		security.notifLabel.visible = false

func _on_physic_process(_delta: float) -> void:
	if security.seePlayer():
			var dirToObj = (security.objInSight.global_position - security.global_position).normalized()
			security.updateAnimation(dirToObj)
