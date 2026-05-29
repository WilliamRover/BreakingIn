class_name Loadout extends Control

var itemSlot: PackedScene = preload("res://Scenes/UI/Loadout/item_slot.tscn")
var containerBtn: PackedScene = preload("res://Scenes/UI/Loadout/container_btn.tscn")
var jsonPath: String = "res://Data/items.json"

@onready var equipVBoxContainer: VBoxContainer = $HBoxContainer/ColorRect/MarginContainer/HBoxContainer/MainContainer/ScrollContainer/EquipItem
@onready var thatOneVBoxContainer: VBoxContainer = $HBoxContainer/ColorRect/MarginContainer/HBoxContainer/AvailableItems/ScrollContainer/AvailableItems
@onready var capacityLabel: Label = $HBoxContainer/ColorRect/MarginContainer/HBoxContainer/MainContainer/Size
@onready var inventoryType: Label = $HBoxContainer/ColorRect/MarginContainer/HBoxContainer/MainContainer/InventoryType
@onready var containerList: VBoxContainer = $HBoxContainer/InventoryChoice
@onready var backMenuBtn: Button = $HBoxContainer/InventoryChoice/MarginContainer/BackToMenu

var activeContainerBtn: String = ""
var itemHash: Dictionary = {}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	loadItem()
	generateContainerBtn()
	#innitItem()
	#allContainer = [onBodyBtn, backpackBtn, beltBtn]
	#onBodyBtn.pressed.connect(btnChoice.bind("OnBody", onBodyBtn))
	#backpackBtn.pressed.connect(btnChoice.bind("Backpack", backpackBtn))
	#beltBtn.pressed.connect(btnChoice.bind("Belt", beltBtn))
	
	backMenuBtn.pressed.connect(backToMenu)

func loadItem() -> void:
	var file = FileAccess.open(jsonPath, FileAccess.READ)
	var jsonStr = file.get_as_text()
	file.close()
	
	var parsedData = JSON.parse_string(jsonStr)
	
	for item in parsedData:
		itemHash[item["id"]] = item

func curCapacity(containerId: String) -> int:
	var totalSize = 0
	var itemIds = PlayerStat.data["inventory"]["container"][containerId]["items"]
	for item in itemIds:
		if itemHash.has(item):
			totalSize += int(itemHash[item]["capacity"])
	return totalSize
	
func generateContainerBtn() -> void:
	var containers = PlayerStat.data["inventory"]["container"]
	var order = PlayerStat.data["inventory"]["containerOrder"]
	var first = true
	
	for key in order:
		if containers.has(key):
			
			var newBtn :Button = containerBtn.instantiate()
			newBtn.text = containers[key]["name"]
			containerList.add_child(newBtn)
		
			newBtn.pressed.connect(_on_container_btn_clicked.bind(key, newBtn))
			if first:
				_on_container_btn_clicked(key, newBtn)
				first = false
	
func _on_container_btn_clicked(key: String, btn: Button) -> void:
	activeContainerBtn = key
	for child in containerList.get_children():
		if child is Button:
			if child == btn:
				child.button_pressed = true
			else:
				child.button_pressed = false
	
	refreshVBox()
	updateLabel()

func refreshVBox() -> void:
	for child in thatOneVBoxContainer.get_children():
		child.queue_free()
	for child in equipVBoxContainer.get_children():
		child.queue_free()
		
	var availableIds = PlayerStat.data["inventory"]["availableLoadout"]
	for id in availableIds:
		if itemHash.has(id):
			innitItem(itemHash[id], thatOneVBoxContainer)
	if activeContainerBtn != "":
		var ids = PlayerStat.data["inventory"]["container"][activeContainerBtn]["items"]
		for id in ids:
			if itemHash.has(id):
				innitItem(itemHash[id], equipVBoxContainer)
	
	
func innitItem(data: Dictionary, parent: Node) -> void:
	var newItem = itemSlot.instantiate()
	parent.add_child(newItem)
	
	newItem.innitData(data)
	newItem.itemClicked.connect(_on_item_click)
func updateLabel() -> void:
	if activeContainerBtn == "":
		return
	var containerData = PlayerStat.data["inventory"]["container"][activeContainerBtn]
	inventoryType.text = containerData["name"]
	capacityLabel.text = str(curCapacity(activeContainerBtn)) + " / " + str(int(containerData["capacity"]))

func _on_item_click(item: ItemSlot) -> void:
	#print(item.itemData["reqSkill"])
	var curParent = item.get_parent()
	var containerData = PlayerStat.data["inventory"]["container"][activeContainerBtn]
	#var reqSkill = item.itemData["reqSkill"]
	
	if curParent == thatOneVBoxContainer:
		var itemSize = int(item.itemData["capacity"])
		var curSize = curCapacity(activeContainerBtn)
		
		if curSize + itemSize > int(containerData["capacity"]):
			return
		item.reparent(equipVBoxContainer)
		containerData["items"].append(item.itemData["id"])
		PlayerStat.data["inventory"]["availableLoadout"].erase(item.itemData["id"])
		PlayerStat.saveGame()
	elif curParent == equipVBoxContainer:
		item.reparent(thatOneVBoxContainer)
		PlayerStat.data["inventory"]["container"][activeContainerBtn]["items"].erase(item.itemData["id"])
		PlayerStat.data["inventory"]["availableLoadout"].append(item.itemData["id"])
		PlayerStat.saveGame()
	updateLabel()
		#print(activeContainerBtn)
		#print(item.itemData["id"])
		#print(PlayerStat.data)
		
#func btnChoice(btnName: String, btn: Button) -> void:
	#match btnName:
		#"OnBody":
			#inventoryType.text = "On body"
			#capacityLabel.text = "0 / 6"
		#"Backpack":
			#inventoryType.text = "Backpack"
			#capacityLabel.text = "0 / 20"
		#"Belt":
			#inventoryType.text = "Belt"
			#capacityLabel.text = "0 / 4"
	#
	#for container in allContainer:
		#if container == btn:
			#container.button_pressed = true
		#else:
			#container.button_pressed = false

func backToMenu() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu/menu.tscn")
