class_name LevelTutorial extends LevelMain

func _ready() -> void:
	var tree = get_tree().root
	var bookshelves = findNearBookshelf(tree)
	var safes = findNearSafe(tree)
	 #Example of doing something with them:
	for safe in safes:
		safe.generateSafeCode()
	await get_tree().process_frame
	distributeIntel(safes, bookshelves)
 #Called when the node enters the scene tree for the first time.

 #The recursive function
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
	
	var intelShelf = shelves.pop_front()
	intelShelf.assignIntel(intelText)
	
	var textArr: Array[String] = getAllText()
	textArr.shuffle()
	
	for shelf in shelves:
		var txt = textArr.pop_front()
		shelf.assignIntel(txt)
func getAllText() -> Array[String]:
	var texts: Array[String] = [
		"""
		HERMANA POLICE DEPARTMENT
		DOMESTIC SECURTIY BUREAU
		
		Date: 21.01.1009
		Subject: Reminder on using quick-response security door issued by Hermana Police Department
		
		Dear sir Leon Golle,
		
		This is a reminder that security door type DSB5 will raise alarm if you leave it open. If your house has a power outage, please make sure the door is close before you turn the power back on, as the door alarm will activate itself after 15 seconds.
		
		Best regards,
		Tomas Torvalds - HPD-DSB Specialist
		""",
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
		"""
	]
	return texts
	
