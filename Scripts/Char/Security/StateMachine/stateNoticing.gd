class_name StateNoticing extends State

var security: Security
var noticeTimer: float = 0
var alertTime: float = 2
var prevStateName: String

func _ready() -> void:
	await owner.ready
	security = owner as Security
	if PlayerStat.checkSkill("slowDetect"):
		alertTime = 5
	
func _on_enter() -> void:
	noticeTimer = 0
	security.detectionBar.visible = true
	security.velocity = Vector2.ZERO
	
	if get_parent().prevState:
		prevStateName = get_parent().prevState.name
		
func _on_physic_process(_delta: float) -> void:
	#print(security.seePlayer())
	if security.seePlayer() == true:
		noticeTimer += _delta
		security.detectionBar.value += _delta
		if security.objInSight:
			var dirToObj = (security.objInSight.global_position - security.global_position).normalized()
			security.updateAnimation(dirToObj)
			#print("upding pos")
		if noticeTimer >= alertTime:
			transitionState.emit(self, "StateAlert")
	else:
		noticeTimer -= _delta
		security.detectionBar.value -= _delta
		if noticeTimer <= 0:
			security.detectionBar.value = 0
			security.detectionBar.visible = false
			transitionState.emit(self, prevStateName)
			return
