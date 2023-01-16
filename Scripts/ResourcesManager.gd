extends Node

const maxItems:int = 4
const itemsMatrix:Vector2 = Vector2(4,1)

var parser:XMLParser = XMLParser.new()

export(int) var windowWidth = ProjectSettings.get_setting("display/window/size/width")
export(int) var windowHeight = ProjectSettings.get_setting("display/window/size/width")

onready var currentWidth:float = get_tree().root.size.x
onready var currentHeight:float = get_tree().root.size.y

func _ready() -> void:
	var error:int = get_tree().root.connect("size_changed",self,"windowResized")
	if error != OK: push_error("Error " + error as String + " while connecting size_changed to windowResized") 

func windowResized() -> void:
	currentWidth = get_tree().root.size.x 
	currentHeight = get_tree().root.size.y

func getPathsIn(folder:String, fillInTarget:Array, extension:String = "") -> void:
	var dir:Directory = Directory.new()
	if dir.open(folder) == OK:
		#warning-ignore:return_value_discarded
		dir.list_dir_begin(true,true)
		var nextPath:String = dir.get_next()
		while nextPath != "":
			if nextPath.ends_with(extension):
				fillInTarget.append(folder + nextPath)
			nextPath = dir.get_next()

func parseXMLRoomFile(filePath:String, target:Dictionary) -> void:
	var openError = parser.open(filePath)
	if openError != OK: push_error("Error " + openError as String + " while opening " + filePath)
	 
	while not parser.read():
		var nodeType:int = parser.get_node_type()
		if parser.get_node_type() == XMLParser.NODE_ELEMENT:
			match parser.get_node_name():
				"MultiAction":
					var multiaction:Array = parseXMLMultiAction()
					if target.has(multiaction[0]):
						push_error("Multiaction already exists: " + multiaction[0])
					target[multiaction[0]] = [multiaction[1], multiaction[2]]
				"SingleAction":
					var action:Array = parseXMLSingleAction()
					if target.has(action[0]):
						push_error("Action already exists: " + action[0])
					target[action[0]] = ["Single", action[1][0], action[1][1]]
				"Text":
					var text:Array = parseXMLText()
					if target.has(text[0]):
						push_error("Text already exists: " + text[0])
					target[text[0]] = text[1]
				"Item":
					var item:Array = parseXMLItem()
					if target.has(item[0]):
						push_error("Text already exists: " + item[0])
					target[item[0]] = item[1]
	print(target)

func parseXMLText() -> Array:
	var ID:String = ""
	var content:String = ""
	
	while not parser.read():
		var nodeType:int = parser.get_node_type()
		match nodeType:
			XMLParser.NODE_ELEMENT:
				var nodeName:String = parser.get_node_name()
				parser.read()
				match nodeName:
					"ID": ID = parser.get_node_data()
					"Content": content = parser.get_node_data()
			XMLParser.NODE_ELEMENT_END:
				if parser.get_node_name() == "Text": return [ID, content]
	
	push_error("Text Element End not found.")
	return []

func parseXMLItem() -> Array:
	var ID:String = ""
	var atlasID:int = -1
	
	while not parser.read():
		var nodeType:int = parser.get_node_type()
		match nodeType:
			XMLParser.NODE_ELEMENT:
				var nodeName:String = parser.get_node_name()
				parser.read()
				match nodeName:
					"ID": ID = parser.get_node_data()
					"AtlasID": atlasID = parser.get_node_data() as int
			XMLParser.NODE_ELEMENT_END:
				if parser.get_node_name() == "Item": 
					if atlasID == -1:
						print("AtlasID: " + atlasID as String)
						push_error("Error adding item " + ID)
					return [ID, atlasID]
	
	push_error("Item Element End not found.")
	return []

func parseXMLSingleAction() -> Array:
	var outArray:Array = []
	var ID:String = ""
	var actionType:String = ""
	var actionArguments:Array = []

	while not parser.read():
		var nodeType:int = parser.get_node_type()
		match nodeType:
			XMLParser.NODE_ELEMENT:
				var nodeName:String = parser.get_node_name()
				parser.read()
				match nodeName:
					"ID": ID = parser.get_node_data()
					"Type": actionType = parser.get_node_data()
					"Arguments": actionArguments = parser.get_node_data().split(" ", false)
			XMLParser.NODE_ELEMENT_END:
				if parser.get_node_name() == "SingleAction":
					if ID == "" or actionType == "":
						push_error("Error adding single action. ID: " + ID + " Type: " + actionType)
					return [ID, [actionType, actionArguments]]
	
	push_error("SingleAction Element End not found.")
	return []

func parseXMLMultiAction() -> Array:
	var outArray:Array = []
	var ID:String = ""
	var condition:Array = [] 
	var nOutputs:int = 0
	var outputs:Array = []
	
	while not parser.read():
		var nodeType:int = parser.get_node_type()
		match nodeType:
			XMLParser.NODE_ELEMENT:
				match parser.get_node_name():
					"ID": 
						parser.read()
						ID = parser.get_node_data()
					"Condition": 
						var fullCondition:Array = parseXMLCondition()
						nOutputs = fullCondition[2]
						condition = [fullCondition[0], fullCondition[1]]
					"Output":
						var output:Array = parseXMLOutput()
						outputs.append(output)
			XMLParser.NODE_ELEMENT_END:
				if parser.get_node_name() == "MultiAction":
					if ID == "" or nOutputs != outputs.size():
						print("Condition outputs: " + nOutputs as String)
						print("Parsed outputs: " + outputs.size() as String) 
						push_error("Error adding multiaction: " + ID)
						return []
					return [ID, condition, outputs]
	
	push_error("MultiAction Element End not found.")
	return []

func parseXMLAction() -> Array:
	var actionType:String = ""
	var actionArguments:Array = []
	while !parser.read():
		var nodeType:int = parser.get_node_type()
		
		match nodeType:
			XMLParser.NODE_ELEMENT:
				var nodeName:String = parser.get_node_name()
				parser.read()
				match nodeName:
					"Type":
						actionType = parser.get_node_data()
					"Arguments":
						actionArguments = parser.get_node_data().split(" ", false)
					_: 
						push_error("Unknown node " + nodeName + " in action.")
			XMLParser.NODE_ELEMENT_END:
				if actionType == "":
					push_error("Error adding action.")
				match parser.get_node_name():
					"Action": 
						return [actionType, actionArguments]
	
	push_error("Action Element End not found.")
	return []

func parseXMLCondition() -> Array:
	var conditionType:String = ""
	var conditionArguments:Array = []
	var conditionNOutputs:int = 0
	
	while not parser.read():
		var nodeType:int = parser.get_node_type()
		match nodeType:
			XMLParser.NODE_ELEMENT:
				var nodeName:String = parser.get_node_name()
				parser.read()
				
				match nodeName:
					"Type": conditionType = parser.get_node_data()
					"Arguments": conditionArguments = parser.get_node_data().split(" ", false)
					"Outputs": conditionNOutputs = parser.get_node_data() as int
			XMLParser.NODE_ELEMENT_END:
				if parser.get_node_name() == "Condition": return [conditionType, conditionArguments, conditionNOutputs]
	
	push_error("MultiAction Element End not found")
	return []

func parseXMLOutput() -> Array:
	var outputArray:Array = []
	
	while not parser.read():
		var nodeType:int = parser.get_node_type()
		match nodeType:
			XMLParser.NODE_ELEMENT:
				if parser.get_node_name() == "Action":
					outputArray.append(parseXMLAction())
			XMLParser.NODE_ELEMENT_END:
				if parser.get_node_name() == "Output":
					return outputArray

	push_error("Output Element End not found")
	return []

#Recheck esta funcion
func parseXMLRoomLoader(filePath:String, targetDict:Dictionary) -> void:
	var openError = parser.open(filePath)
	if openError != OK: push_error("Error " + openError as String + " while opening " + filePath)
	
	var roomName:String
	var neighbours:Array = []
	
	while not parser.read():
		if parser.get_node_type() == XMLParser.NODE_ELEMENT and parser.get_node_name() == "LoadRoom": continue

		if parser.get_node_type() == XMLParser.NODE_ELEMENT:
			var propertyName:String = parser.get_node_name()
			var error:int = parser.read()
			if error != OK: push_error("Error " + error as String + " while reading the file " + filePath) 
			
			if parser.get_node_type() == 3:
				var data:String = parser.get_node_data()
				match propertyName:
					"Name":
						roomName = data
					"Neighbours":
						neighbours = data.split(" ", false)
	targetDict[roomName] = neighbours
