class_name Multimeter extends Node2D

@onready var wire: Line2D = $Line2D
@onready var fixedPoint: Marker2D = $FixedPoint
@onready var wireEnd: Node2D = $WireEnd
@onready var voltLabel: Label = $Voltage

@export var sagAmount := 200
@export var segment := 100
@export var maxDragSpeed := 1000
var dragNode: Node2D = null

func _ready() -> void:
	var drag1 = wireEnd.get_node("Entire")
	drag1.input_event.connect(_on_drag_area_input_event.bind(wireEnd))
	voltLabel.text = "0V"
	updateWire()

func _physics_process(delta: float) -> void:
	if dragNode != null:
		var pos = get_global_mouse_position()
		dragNode.global_position = dragNode.global_position.move_toward(pos, maxDragSpeed * delta)
		updateWire()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed:
			dragNode = null

func _on_drag_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int, wire_end_node: Node2D) -> void:
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragNode = wire_end_node

func updateWire() -> void:
	var pos1 = fixedPoint.position
	var pos2 = wireEnd.position + Vector2(0, 150)
	
	var midPos = (pos1 + pos2) / 2
	midPos.y += sagAmount
	wire.clear_points()
	
	for i in range(segment + 1):
		var t = float(i) / segment
		var point = _calculate_bezier_point(t, pos1, midPos, pos2)
		wire.add_point(point)
func _calculate_bezier_point(t: float, p0: Vector2, p1: Vector2, p2: Vector2) -> Vector2:
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)
	return q0.lerp(q1, t)


func displayVoltage(lowVoltage: bool = true) -> void:
	if lowVoltage:
		voltLabel.text = str(round_place(RandomNumberGenerator.new().randf_range(0, 6), 1)) + "V"
	else:
		voltLabel.text = str(round_place(RandomNumberGenerator.new().randf_range(230, 260), 1)) + "V"
		
func round_place(num,places):
	return (round(num*pow(10,places))/pow(10,places))
