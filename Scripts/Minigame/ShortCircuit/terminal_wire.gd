class_name TerminalWire extends Area2D

signal wireTipEntered2(body: Node2D, origin: Node2D)
signal wireTipExited2(body: Node2D, origin: Node2D)
func _on_body_entered(body: Node2D) -> void:
	if body is WireTip:
		wireTipEntered2.emit(self, body)

func _on_body_exited(body: Node2D) -> void:
	if body is WireTip:
		wireTipExited2.emit(self, body)
