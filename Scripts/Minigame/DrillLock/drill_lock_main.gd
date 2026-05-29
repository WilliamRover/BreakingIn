extends Node2D

@onready var drillMain: CharacterBody2D = $Drill
signal lockDrilled()

func _on_lock_body_entered(body: Node2D) -> void:
	if body == drillMain:
		drillMain.move = false
		$Drill/DrillLoop.stop()
		$Drill/DrillStart.stop()
		$Drill/DrillEnd.play()
		$LockBreak.play()
		lockDrilled.emit()

func getDrillPos() -> Vector2:
	return drillMain.position

func setDrillPos(pos: Vector2) -> void:
	drillMain.position = pos
