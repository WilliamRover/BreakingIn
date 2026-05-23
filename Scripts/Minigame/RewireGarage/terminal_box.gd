class_name TerminalBox extends Area2D

signal wireTipEntered(body: Node2D)
signal wireTipExited(body: Node2D)
func _on_body_entered(body: Node2D) -> void:
	if body is WireTip:
		wireTipEntered.emit(self)

func _on_body_exited(body: Node2D) -> void:
	if body is WireTip:
		wireTipExited.emit(self)
