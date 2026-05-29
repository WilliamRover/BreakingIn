class_name ItemSlot extends MarginContainer

signal itemClicked(item: ItemSlot)

@onready var itemName: Label = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/ItemName
@onready var itemReq: Label = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/ItemReq
@onready var itemIcon: TextureRect = $PanelContainer/MarginContainer/HBoxContainer/Icon

var itemData: Dictionary = {}

func innitData(data: Dictionary) -> void:
	itemData = data
	itemName.text = data["itemName"]
	itemIcon.texture = load(data["imgPath"])
	itemReq.hide()
	if data["reqSkill"] != "":
		var unlockedSkills = PlayerStat.data["skills"]
		if data["reqSkill"] not in unlockedSkills:
			if DatabaseManager.skills.has(data["reqSkill"]):
				itemReq.text = "Required " + DatabaseManager.skills[data["reqSkill"]]["skillName"]
			itemReq.show()
		else:
			itemReq.hide()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			itemClicked.emit(self)
