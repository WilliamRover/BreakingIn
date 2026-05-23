class_name LoadingScreen extends Control

func _ready():
	var target = GlobalSignal.targetScenePath
	if target != "":
		ResourceLoader.load_threaded_request(target)

func _process(delta: float) -> void:
	var targetScene = GlobalSignal.targetScenePath
	var progress = []
	ResourceLoader.load_threaded_request(targetScene)
	ResourceLoader.load_threaded_get_status(targetScene, progress)
	$MarginContainer/VBoxContainer/ProgressBar.value = progress[0] * 100
	$MarginContainer/VBoxContainer/PercentNum.text = str(round(progress[0] * 100)) + "%"
	
	if progress[0] == 1:
		var packedScene = ResourceLoader.load_threaded_get(targetScene)
		get_tree().change_scene_to_packed(packedScene)
