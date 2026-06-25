class_name StateMachine extends Node

@export var innitState: State
var curState: State
var prevState: State

func _ready() -> void:
	await owner.ready
	
	for child in get_children():
		if child is State:
			child.transitionState.connect(_on_state_transition)
	if innitState:
		innitState._on_enter()
		curState = innitState


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if curState:
		curState._on_process(delta)
	#print(curState)

func _physics_process(delta: float) -> void:
	#print(curState)
	if curState:
		curState._on_physic_process(delta)
		

func _on_state_transition(state: State, stateName: String) -> void:
	if state != curState:
		return
	
	var newState: State = get_node(stateName)
	if !newState:
		return
	if curState:
		curState._on_exit()
		prevState = curState
	
	newState._on_enter()
	curState = newState
