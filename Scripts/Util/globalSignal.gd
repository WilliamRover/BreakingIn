extends Node

signal openGarage(targetId: String)
signal turnLight(taretId: String, overload: bool)
var targetScenePath: String = ""
signal playerClimbed(inside: bool, curFloor: int)
signal updRoofVisibility(aboveFloors: int)
#var allLightsOn: bool
