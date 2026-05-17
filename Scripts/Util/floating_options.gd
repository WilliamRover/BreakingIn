class_name FloatingOption extends VBoxContainer

signal btn_pressed(btnName: String)
var targetNode: Node2D = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for btn: Button in get_children():
		btn.pressed.connect(_btn_pressed.bind(btn.name))
	

func _btn_pressed(btnName: String):
	btn_pressed.emit(btnName)
	print("signal sent")
	hide()
# Called every frame. 'delta' is the elapsed time since the previous frame.
		
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and visible:
		btn_pressed.emit()
		hide()
