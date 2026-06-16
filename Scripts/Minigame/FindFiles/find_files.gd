class_name FindFiles extends Node2D

@onready var intel: Label = $ScrollContainer/Control/Intel

signal provideIntel(content: String)

func _ready() -> void:
	provideIntel.connect(writeIntel)

func writeIntel(content: String) -> void:
	intel.text = content
