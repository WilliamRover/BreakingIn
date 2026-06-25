class_name StateRandomWalk extends State

var security: Security

func _ready() -> void:
	await owner.ready
	security = owner as Security

func _on_enter() -> void:
	var destArrSize = security.dest.size()
	
	if destArrSize > 1:
		var newIdx = security.curNavIdx
		
		while newIdx == security.curNavIdx:
			newIdx = randi_range(0, destArrSize - 1)
		security.curNavIdx = newIdx
	security.nav.target_position = security.dest[security.curNavIdx]

func _on_physic_process(_delta: float) -> void:
	if security.nav.is_navigation_finished():
		transitionState.emit(self, "StateIdle")
		return
	var curPos = security.global_position
	#print(curPos)
	var nxtPathPos = security.nav.get_next_path_position()
	var dir = (nxtPathPos - curPos).normalized()
	security.velocity = dir * security.SPEED
	security.move_and_slide()
	security.updateAnimation(dir)
	
	if security.seePlayer():
		transitionState.emit(self, "StateNoticing")
		return
