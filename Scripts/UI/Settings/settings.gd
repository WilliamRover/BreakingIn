class_name Settings extends Control

@onready var returnBtn: Button = $Bg/MarginContainer/VBoxContainer/Return

@onready var labelMaster: Label = $Bg/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/Master
@onready var labelBgMusic: Label = $Bg/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/BgMusic
@onready var labelSfx: Label = $Bg/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/Sfx

@onready var sliderMaster: Slider = $Bg/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Master
@onready var sliderBgMusic: Slider = $Bg/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/BgMusic
@onready var sliderSfx: Slider = $Bg/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Sfx

@onready var sliderMasterNum: Label = $Bg/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer3/Master
@onready var sliderBgMusicNum: Label = $Bg/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer3/BgMusic
@onready var sliderSfxNum: Label = $Bg/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer3/Sfx

@onready var busIdxMaster = AudioServer.get_bus_index("Master")
@onready var busIdxBgMusic = AudioServer.get_bus_index("BgMusic")
@onready var busIdxSfx = AudioServer.get_bus_index("Sfx")

func _ready() -> void:
	returnBtn.pressed.connect(closeSettings)
	#var curMasterDb = AudioServer.get_bus_volume_db(busIdxMaster)
	#var curBgMusicDb = AudioServer.get_bus_volume_db(busIdxBgMusic)
	#var curSfxDb = AudioServer.get_bus_volume_db(busIdxSfx)
	
	SettingSaves.loadGame()
	sliderMaster.value = float(SettingSaves.data["masterVol"])
	sliderBgMusic.value = float(SettingSaves.data["bgMusicVol"])
	sliderSfx.value = float(SettingSaves.data["sfxVol"])

func closeSettings() -> void:
	if get_parent() is PauseOverlay:
		visible = false
		return

func _on_master_value_changed(value: float) -> void:
	var linearVol = value / 100
	var dbVol = linear_to_db(linearVol)
	AudioServer.set_bus_volume_db(busIdxMaster, dbVol)
	sliderMasterNum.text = str(int(sliderMaster.value))
	SettingSaves.data["masterVol"] = str(int(sliderMaster.value))
	SettingSaves.saveGame()

func _on_bg_music_value_changed(value: float) -> void:
	var linearVol = value / 100
	var dbVol = linear_to_db(linearVol)
	AudioServer.set_bus_volume_db(busIdxBgMusic, dbVol)
	sliderBgMusicNum.text = str(int(sliderBgMusic.value))
	SettingSaves.data["bgMusicVol"] = str(int(sliderMaster.value))
	SettingSaves.saveGame()

func _on_sfx_value_changed(value: float) -> void:
	var linearVol = value / 100
	var dbVol = linear_to_db(linearVol)
	AudioServer.set_bus_volume_db(busIdxSfx, dbVol)
	sliderSfxNum.text = str(int(sliderSfx.value))
	SettingSaves.data["sfxVol"] = str(int(sliderMaster.value))
	SettingSaves.saveGame()
	
