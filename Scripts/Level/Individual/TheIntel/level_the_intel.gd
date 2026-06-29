class_name TheIntel extends LevelMain

@onready var player: Player = $Player
@onready var bgMusic: AudioStreamPlayer = $BgMusic
@onready var escapeMusic: AudioStreamPlayer = $EscapeMusic
@onready var cutsceneCam: Camera2D = $PoliceArrivedCam
@onready var exfiltrateZone: Area2D = $Level0/ExfiltrateZone

@onready var police1: PoliceCar = $Level0/PoliceCar
@onready var police2: PoliceCar = $Level0/PoliceCar2
@onready var police3: PoliceCar = $Level0/PoliceCar3
@onready var police4: PoliceCar = $Level0/PoliceCar4

@onready var policePosDict: Dictionary = {
	police1: Vector2(3904.0, 2539.0),
	police2: Vector2(3928.0, 2812.0),
	police3: Vector2(4914.0, 2621.0),
	police4: Vector2(5282.0, 2674)
}


var safeCracked: bool = false
var secDoorOpened: bool = false

var canExfiltrate: bool = false
var exfiltrate: bool = false

var missionObjCont: Array[String] = [
	'''Entry point:
		- The compound has an archive room
		- Opening the front entrance will raise alarm
	''',
	'''		- Intel: front entrance alarm is wired to the restaurant's power box
	''',
	'''		- Intel: garage door can be rewired in a small 2nd building 
			bridged with the main building
	''',
	'''Inside the compound:
		- Building is packed with securities
		- Find a way to get to the saferoom
	''',
	'''Victory ahead:
		- Locate the safe code
			- Search each office for partial code
	''',
	'''		- Exfiltrate'''
]
var totalCont: String = missionObjCont[0]
var safeCode: Array[String] = ["00", "00", "00"]

var fallBackArchive: String = '''I guess this is a blank paper'''

var secDoorIntelFound: bool = false
var garageIntelFound: bool = false
var enteredCompound: bool = false
var floor1: bool = true
var floor2: bool = false

func _enter_tree() -> void:
	super()
	LevelStat.updLevelStat("missionTitle", "title", "The intel")
	
func _ready() -> void:
	super()
	#for content in missionObjCont:
		#totalCont += content
	player.screenUI.setMissionObjectiveContent(totalCont)
	GlobalSignal.safeItemRetrieved.connect(itemRetrieved)
	#GlobalSignal.doorWinInteracted.connect(secDoorInteracted)
	GlobalSignal.exfilPos.emit(exfiltrateZone.global_position)
	bgMusic.play()
	var tree = get_tree().root
	var bookshelves = findNearBookshelf(tree)
	var safes = findNearSafe(tree)
	for safe in safes:
		safe.generateSafeCode()
	for shelf in bookshelves:
		shelf.intelFound.connect(onIntelFound)
	await get_tree().process_frame
	distributeIntel(safes, bookshelves)


func callPolice() -> void:
	player.startTimer(12)
	bgMusic.stop()
	escapeMusic.play()
	
	player.screenUI.countdownTimer.timeout.connect(policeArrived)
	for policeCar in policePosDict.keys():
		policeCar.spawnPolice()
		await get_tree().create_timer(0.25).timeout
	#print("policeCalled")

func policeArrived() -> void:
	var tween = get_tree().create_tween().set_parallel(true)
	
	for policeCar in policePosDict:
		var targetPos = policePosDict[policeCar]
		tween.tween_property(policeCar, "global_position", targetPos, 5).set_trans(Tween.TRANS_SINE)
	cutsceneCam.make_current()
	if exfiltrate == false:
		escapeMusic.stop()
		GlobalSignal.updRoofVisibility.emit(0)
	
		player.movable = false
		await get_tree().create_timer(7.5).timeout
		player.saveElapsedTime()
		gameOverOverlayScene.gameOver()

func findNearBookshelf(node: Node, result: Array = []) -> Array:
	if node is NearBookShelf:
		result.push_back(node)
	for child in node.get_children():
		findNearBookshelf(child, result)
	return result

func findNearSafe(node: Node, result: Array = []) -> Array:
	if node is NearSafe:
		result.push_back(node)
	for child in node.get_children():
		findNearSafe(child, result)
	return result

func distributeIntel(safes: Array, shelves: Array) -> void:
	shelves.shuffle()
	var curSafe = safes[0]
	var rawCode = LevelStat.getLevelStat(curSafe.safeId, "safeCode", ["00", "00", "00"])
	safeCode = [rawCode[0], rawCode[1], rawCode[2]]
	
	var floor1archive: Array[Dictionary] = [
		{"text":
		'''
		Dear Leon,
		For the last time, the entrance door alarm is wired to THE RESTAURANT, not the 1st floor power box!!! Stop shutting down the entire building power just to trigger the alarm right after that!
		
		Best regards,
		Sam''',
		"id": "secDoorIntel"},
		{"text":
		'''
		HERMANA POLICE DEPARTMENT
		DOMESTIC SECURTIY BUREAU
		
		Date: 03.02.1010
		Subject: Reminder on using quick-response security door issued by Hermana Police Department
		
		Hello,
		
		This is a suggestion to train the staff what power box to tamper when they want to enter the building, as police will response immidiately to the alarm. Specifically, your front entrance alarm is wired to the nearby restaurant, while the rest is wired to the 1st floor power box.
		
		Best regards,
		Colas Sivonen - HPD-DSB Specialist''',
		"id": "secDoorIntel"},
		{"text":
		'''
		TODO: Contact an electrician to remove garage switch on the 2nd building bridged with the main building, and replace the switch with a remote control
		''',
		"id": "garageIntel"},
		{"text":
		'''
		Date: 04.07.1001
		
		Hey,
		Apparently the construction team didn't read the building plan carefully, so now if we want to install a garage switch right outside, we would have to break a bunch of walls for it. There is an unfinished second building bridged with the main building, so maybe you can utilise it and wire the garage switch there.
		
		Have a good day
		
		- Happa, Contruction Manager
		''',
		"id": "garageIntel"},
		{"text":
		'''
		Reminder to all staff:
		
		The company uses DD.MM.YYYY format, not MM.DD.YYYY format. Now if any of you document some papers in the incorrect format, please make changes right of.
		''',
		"id": ""},
		{"text":
		'''
		To Steve,
		Do not slack off during the night. We don't hire people just to periodically wake you up during the shift.
		''',
		"id": ""},
		{"text":
		'''
		From: Havan Pivoten - Security lead
		To: @security_department
		
		Dear security team,
		Due to recent rise in burglar attempt during the night, I will assign a few of you from the day shifts to the evening and night shifts.
		
		Detailed changes will be covered in the meeting tomorrow, which I send in a seperate email.
		
		Best,
		Havan Pivoten''',
		"id": ""},
		{"text":
		'''
		Dear Analytic team,
		Please do not use Stetson-Harrison method for your ananlysis. We hired you to analyze real-time data, not to pull the number and conclusion out of nowhere.''',
		"id": ""},
		{"text":
		'''
		Subject: Schedule changes for fire exercise
		From: Havan Pivoten - Security lead
		To: @2nd_floor_personnel
		
		Dear personnel,
		Since there will be heavy rain on 17th November, we will do the exercise on the 20th November. The exercise location remain the same.
		
		Best wishes,
		Havan Pivoten
		''',
		"id": ""},
		{"text":
		'''
		To software developer intern,
		DO NOT CHANGE THE LEGACY CODE. THERE WAS A /*DO NOT CHANGE THIS FUNCTION*/ COMMENT FOR A REASON.
		''',
		"id": ""},
		{"text":
		'''
		To software developer intern,
		
		I said send the public rsa key to me so I can authorize access to you, not the entire rsa key folder that also contains your private key. Go back and generate a new pair of key please.
		''',
		"id": ""},
		{"text":
		'''
		To software developer intern,
		
		ALWAYS include the WHERE clause if you use DELETE FROM table. I got a bunch of email warnings about some of you attempting to delete THE ENTIRE DATABASE.
		''',
		"id": ""},
	] # 12 shelves

	var floor2archive: Array[String] = [
		'''
		Generated 1st safe code: {safeCode} __ __
		'''.format({"safeCode": safeCode[0]}),
		'''
		Generated 2nd safe code: __ {safeCode} __
		'''.format({"safeCode": safeCode[1]}),
		'''
		Generated 3rd safe code: __ __ {safeCode}
		'''.format({"safeCode": safeCode[2]}),
		'''
		TODO: Finish authorizing access for the interns
		''',
		'''
		TODO: Touch grass
		''',
		'''
		TODO: Finish this game
		''',
		'''
		TODO: Fix stairs switching layers issue
		''',
		'''
		TODO: Fix securities is visible by any other source of light than the vision cone
		''',
		'''
		TODO: Finish the 2nd map
		''',
		'''
		TODO: Fix 2nd floor Occlusion layer interfering with 1st floor
		''',
		'''
		TODO: Fix NPC can see through walls
		'''
	] # 10 shelves
	
	floor1archive.shuffle()
	floor2archive.shuffle()
	
	for shelf in shelves:
		var level_name = shelf.get_parent().get_parent().name
		
		if level_name == "Level0":
			if floor1archive.size() > 0:
				var txt = floor1archive.pop_front()
				shelf.assignIntel(txt["text"], txt["id"])
			else:
				shelf.assignIntel(fallBackArchive)
				
		elif level_name == "Level1":
			if floor2archive.size() > 0:
				var txt = floor2archive.pop_front()
				shelf.assignIntel(txt)
			else:
				shelf.assignIntel(fallBackArchive)
				
		else:
			shelf.assignIntel(fallBackArchive)

func itemRetrieved(_safe: NearSafe) -> void:
	canExfiltrate = true
	exfiltrateZone.visible = true
	totalCont += missionObjCont[5]
	player.screenUI.setMissionObjectiveContent(totalCont)
	player.startExfiltrate()

func onIntelFound(intelId: String) -> void:
	match intelId:
		"secDoorIntel":
			if secDoorIntelFound == false:
				secDoorIntelFound = true
				totalCont += missionObjCont[1]
				player.screenUI.setMissionObjectiveContent(totalCont)
		"garageIntel":
			if garageIntelFound == false:
				garageIntelFound = true
				totalCont += missionObjCont[2]
				player.screenUI.setMissionObjectiveContent(totalCont)


func _on_interior_zone_body_entered(body: Node2D) -> void:
	if body is Player:
		if enteredCompound == false && floor1 == true && (secDoorIntelFound == true || garageIntelFound == true):
			enteredCompound = true
			totalCont += missionObjCont[3]
			player.screenUI.setMissionObjectiveContent(totalCont)


#func _on_interior_zone_floor2_body_entered(body: Node2D) -> void:
	#if body is Player && floor1 == false:
		#totalCont += missionObjCont[4]
		#player.screenUI.setMissionObjectiveContent(totalCont)
		#print(player.curFloor)


func _on_exfiltrate_zone_body_entered(body: Node2D) -> void:
	if canExfiltrate == true:
		exfiltrate = true
		gameCompletedOverlayScene.addTaskCompleted("Retrieved a ton of money", 1250)
		player.saveElapsedTime()
		await get_tree().create_timer(1).timeout
		player.movable = false
		gameCompletedOverlayScene.gameCompleted()
		#PlayerStat.unlockNextMission("The scout")


func _on_second_floor_obj_body_entered(body: Node2D) -> void:
	if body is Player && player.curFloor != 1:
		floor1 = false
		if floor2 == false:
			floor2 = true
			totalCont += missionObjCont[4]
			player.screenUI.setMissionObjectiveContent(totalCont)
