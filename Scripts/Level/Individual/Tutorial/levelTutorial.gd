class_name LevelTutorial extends LevelMain

@onready var player: Player = $Player
@onready var bgMusic: AudioStreamPlayer = $BgMusic
@onready var escapeMusic: AudioStreamPlayer = $EscapeMusic
@onready var policeCar: PoliceCar = $Level0/PoliceCar
@onready var cutsceneCam: Camera2D = $PoliceArrivedCam
@onready var exfiltrateZone: Area2D = $Level0/ExfiltrateZone


@onready var gameInstructions: Array[Label] = [
	$CanvasLayer/GameInstruction/TurnOnFlashLight,
	$CanvasLayer/GameInstruction/ZoomingCam,
	$CanvasLayer/GameInstruction/GetOutOfForest,
	$CanvasLayer/GameInstruction/ApproachHouse,
	$CanvasLayer/GameInstruction/ApproachHouse2,
	$CanvasLayer/GameInstruction/BreachHouseME1,
	$CanvasLayer/GameInstruction/BreachHouseEE1,
	$CanvasLayer/GameInstruction/BreachHouseME2,
	$CanvasLayer/GameInstruction/BreachHouseEE2,
	$CanvasLayer/GameInstruction/BreachHouseME3,
	$CanvasLayer/GameInstruction/BreachHouseEE3,
	$CanvasLayer/GameInstruction/Patrolling,
	$CanvasLayer/GameInstruction/SecurityDoor,
	$CanvasLayer/GameInstruction/Safe,
	$CanvasLayer/GameInstruction/Patrolling2,
	$CanvasLayer/GameInstruction/Escape,
	$CanvasLayer/GameInstruction/Escape2,
	$CanvasLayer/GameInstruction/Nimble
]

var policePos1 := Vector2(-1371, -710)
var policePos2 := Vector2(5388, 3057)

var floor1: bool = true
var safeCracked: bool = false
var secDoorOpened: bool = false

var canExfiltrate: bool = false
var exfiltrate: bool = false

func _enter_tree() -> void:
	super()
	LevelStat.updLevelStat("missionTitle", "title", "The rookie (TUTORIAL)")
	

func _ready() -> void:
	super()
	GlobalSignal.safeItemRetrieved.connect(itemRetrieved)
	GlobalSignal.doorWinInteracted.connect(secDoorInteracted)
	bgMusic.play()
	var tree = get_tree().root
	var bookshelves = findNearBookshelf(tree)
	var safes = findNearSafe(tree)
	for safe in safes:
		safe.generateSafeCode()
	await get_tree().process_frame
	distributeIntel(safes, bookshelves)
	
	if PlayerStat.checkSkill("mechanicalEngineer"):
		gameInstructions[5].visible = true
		gameInstructions[7].visible = true
	elif PlayerStat.checkSkill("electricalEngineer"):
		gameInstructions[6].visible = true
		gameInstructions[8].visible = true

func _input(event: InputEvent) -> void:
	if gameInstructions[0].visible == true:
		if event.is_action("ILLUMINATOR MENU - T"):
			gameInstructions[0].visible = false
			gameInstructions[1].visible = true
	
	if gameInstructions[1].visible == true:
		if event.is_action_pressed("MMOUSE ROLL UP") || event.is_action_pressed("MMOUSE ROLL DOWN"):
			await get_tree().create_timer(2.5).timeout
			gameInstructions[1].visible = false
			gameInstructions[17].visible = true
	
	if gameInstructions[17].visible == true:
		if event.is_action_pressed("RMOUSE"):
			await get_tree().create_timer(2.5).timeout
			gameInstructions[17].visible = false
			gameInstructions[2].visible = true
	

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
	var safeCode = rawCode[0] + rawCode[1]+ rawCode[2]
	
	var intelText = """
	ULTRASAFE COMP                     info@mechsafe.ui
	
	Date: 13.07.1009 - 14:47
	Customer: Leon Golle
	Issue description: "Hi, could you send someone to go and reset the safe for me? I seems to forgot the safe code. I have the receipt and proof of ownership of the safe available."
	
	The following are transcript of customer's issue and company's staff.
	Note that transcript full details is only available by clicking Your Profile > Issues log. Otherwise some details are blacked-out for security purpose.
	
	**START OF TRANSCRIPT**
	13.07.1009 - 15:02
	[Serbe Parkila - Customer Service]: Hello and thanks for contacing us. What is your address and when can we come to your place?
	
	13.07.1009 - 15:05
	[Leon Golle - Customer]: My address is Nonamekatu 12. You can come by anytime within this week and from 8am to 8pm
	
	13.07.1009 - 15:25
	[Lazara Paunonen - Maintenance Coordinator]: We have contacted a maintenance tech to come by your place at 14:00 tomorrow
	
	14.07.1009 - 14:03
	[Hamella Pekkonen - Mechanical Safe Tech]: **STARTED FAULT REPORT**
	
	14.07.1009 - 14:36
	[Hamella Pekkonen - Mechanical Safe Tech]: **SAFE CODE RESETTED. NEW CODE IS {safeCode}**
	
	14.07.1009 - 15:15
	[Hamella Pekkonen - Mechanical Safe Tech]: **MARKED FAULT REPORT AS FINISHED**
	**END OF TRANSCRIPT**
	""".format({"safeCode": safeCode})
	
	var doorConfigIntel: String = """
		HERMANA POLICE DEPARTMENT
		DOMESTIC SECURTIY BUREAU
		
		Date: 21.01.1009
		Subject: Reminder on using quick-response security door issued by Hermana Police Department
		
		Dear sir Leon Golle,
		
		This is a reminder that security door type DSB5 will raise alarm if you leave it open. Although the alarm won't be activated if the power is down, if your house has a power outage, please make sure the door is close before you turn the power back on, as the door alarm will activate itself after 15 seconds.
		
		Best regards,
		Tomas Torvalds - HPD-DSB Specialist
		"""
	#var intelShelf = shelves.pop_front()
	#intelShelf.assignIntel(intelText)
	
	var textArr: Array[String] = getAllText()
	textArr.shuffle()
	
	var assignedSafeCode: bool = false
	var assignedDoorIntel: bool = false
	for shelf in shelves:
		if textArr.size() > 0:
			#print(shelf.get_parent().get_parent().name)
			if shelf.get_parent().get_parent().name == "Level0" && assignedSafeCode == false:
				shelf.assignIntel(intelText)
				assignedSafeCode = true
				#textArr.pop_front()
				continue
			elif shelf.get_parent().get_parent().name == "Level1" && assignedDoorIntel == false:
				shelf.assignIntel(doorConfigIntel)
				assignedDoorIntel = true
				#textArr.pop_front()
				continue
			var txt = textArr.pop_front()
			shelf.assignIntel(txt)
		else:
			shelf.assignIntel("This is a reminder to the developer of this game is that you missed a text")
func getAllText() -> Array[String]:
	var texts: Array[String] = [
		'''
		This is a beautifutl piece of ASCII art (whitehouse by Joan G. Stark (Spunk)):
			
			
								 _ _.-'`-._ _
								;.'________'.;
					 _________n.[____________].n_________
					|""_""_""_""||==||==||==||""_""_""_""]
					|"""""""""""||..||..||..||"""""""""""|
					|LI LI LI LI||LI||LI||LI||LI LI LI LI|
					|.. .. .. ..||..||..||..||.. .. .. ..|
					|LI LI LI LI||LI||LI||LI||LI LI LI LI|
				 ,,;;,;;;,;;;,;;;,;;;,;;;,;;;,;;,;;;,;;;,;;,,
				;;jgs;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		''',
		"""
		EMPLOYEE INFORMATION
		
		Name: Leon Golle
		Birthdate: 29.01.987
		Role: Security coordinator
		""",
		"""
		Did you know?
		
		To end an online game peacefully, dearly press Alt+F4.
		""",
		"""
		Remember to remove the French language pack in Linux by running the command:
		sudo rm -rf /*
		"""
	]
	return texts
	
func callPolice() -> void:
	player.startTimer(45)
	bgMusic.stop()
	escapeMusic.play()
	
	player.screenUI.countdownTimer.timeout.connect(policeArrived)
	policeCar.spawnPolice()
	#print("policeCalled")

func policeArrived() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(policeCar, "global_position", policePos2, 5).set_trans(Tween.TRANS_SINE)
	cutsceneCam.make_current()
	if exfiltrate == false:
		escapeMusic.stop()
	
		player.movable = false
		await get_tree().create_timer(7.5).timeout
		player.saveElapsedTime()
		gameOverOverlayScene.gameOver()
	#print("police arrived")


func _on_interior_zone_body_entered(body: Node2D) -> void:
	if body is Player:
		if floor1 == true && safeCracked == false:
			gameInstructions[2].visible = false
			gameInstructions[3].visible = false
			gameInstructions[4].visible = false
			if PlayerStat.checkSkill("mechanicalEngineer"):
				gameInstructions[5].visible = false
				gameInstructions[7].visible = false
				gameInstructions[9].visible = true
			elif PlayerStat.checkSkill("electricalEngineer"):
				gameInstructions[6].visible = false
				gameInstructions[8].visible = false
				gameInstructions[10].visible = true
			gameInstructions[11].visible = true
		if safeCracked:
			pass

func _on_interior_zone_body_exited(_body: Node2D) -> void:
	floor1 = false
#
#func _on_interior_zone2_body_entered(body: Node2D) -> void:
	#if body is Player:
		#print(floor1)
		#if floor1 == false:
			#gameInstructions[9].visible = false
			#gameInstructions[10].visible = false
			#gameInstructions[11].visible = false
			#gameInstructions[12].visible = true


func secDoorInteracted(secDoor: Near, _open: bool) -> void:
	if secDoor is NearSecurityDoor:
		gameInstructions[12].visible = false
		gameInstructions[13].visible = true
		gameInstructions[14].visible = true
		secDoorOpened = true

func safeIsCracked(_safe: NearSafe) -> void:
	safeCracked = true
	gameInstructions[13].visible = false
	gameInstructions[14].visible = false
	gameInstructions[15].visible = true
	gameInstructions[16].visible = true
	
	await get_tree().create_timer(20).timeout
	GlobalSignal.triggerCallPoliceSignal()


func _on_entered_2_nd_floor_body_entered(body: Node2D) -> void:
	if body is Player:
		if safeCracked == false && secDoorOpened == false:
			gameInstructions[9].visible = false
			gameInstructions[10].visible = false
			gameInstructions[11].visible = false
			gameInstructions[12].visible = true
			floor1 = false

func itemRetrieved(_safe: NearSafe) -> void:
	canExfiltrate = true
	exfiltrateZone.visible = true
	


func _on_exfiltrate_zone_body_entered(_body: Node2D) -> void:
	if canExfiltrate == true:
		exfiltrate = true
		gameCompletedOverlayScene.addTaskCompleted("Retrieved money and next misison intel", 650)
		player.saveElapsedTime()
		await get_tree().create_timer(1).timeout
		player.movable = false
		gameCompletedOverlayScene.gameCompleted()
		PlayerStat.unlockNextMission("The scout")
