extends Camera2D

@export var minZoom := 0.9
@export var maxZoom := 3.0
@export var zoomSpeed := 0.15

var canZoom: bool = true

func _ready() -> void:
	make_current()

func _input(event: InputEvent) -> void:
	if canZoom:
		var newZoom: Vector2 = zoom
		if event.is_action_pressed("MMOUSE ROLL UP"):
			newZoom += Vector2(zoomSpeed, zoomSpeed)
		elif event.is_action_pressed("MMOUSE ROLL DOWN"):
			newZoom -= Vector2(zoomSpeed, zoomSpeed)
			
		if newZoom >= Vector2(maxZoom, maxZoom):
			newZoom = Vector2(maxZoom, maxZoom)
		if newZoom <= Vector2(minZoom, minZoom):
			newZoom = Vector2(minZoom, minZoom)
		zoom = newZoom

func setZoom(flag: bool) -> void:
	canZoom = flag
