# INTERFACE CLASS
class_name State extends Node

@warning_ignore("unused_signal")
signal transitionState(state: State, stateName: String)

func _on_enter() -> void:
	pass

func _on_exit() -> void:
	pass

func _on_process(_delta: float) -> void:
	pass
	

func _on_physic_process(_delta: float) -> void:
	pass
	
