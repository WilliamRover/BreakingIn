extends Node


@warning_ignore("unused_signal")
signal openGarage(targetId: String)
@warning_ignore("unused_signal")
signal turnLight(taretId: String, overload: bool)
var targetScenePath: String = ""
@warning_ignore("unused_signal")
signal playerClimbed(inside: bool, curFloor: int)
@warning_ignore("unused_signal")
signal updRoofVisibility(aboveFloors: int)
@warning_ignore("unused_signal")
signal callPolice()
var policeCalled: bool = false
func triggerCallPoliceSignal() -> void:
	#print(policeCalled)
	if policeCalled == true:
		return
	policeCalled = true
	callPolice.emit()

@warning_ignore("unused_signal")
signal safeCracked(safe: NearSafe)
@warning_ignore("unused_signal")
signal safeItemRetrieved(safe: NearSafe)
@warning_ignore("unused_signal")
signal doorWinInteracted(secDoor: Near, open: bool)
