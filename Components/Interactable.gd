tool
extends Control

export(String) var uniqueName:String = ""
export(Array, String) var actionIDs:Array = [""]
export(String) var switchMode:String = "None"
export(bool) var oneShot:bool = false

var room:Room = null
var currentActionID:String = ""

func _ready() -> void:
	if Engine.editor_hint:
		resizeRef()
	else:
		get_node("ReferenceRect").queue_free()
		if !(get_parent() is Room): 
				push_warning("Interacatable not in a room. Name: " + uniqueName + ", removing.")
				queue_free()
				return
		room = get_parent()
		room.interactablesArray.append(self)

func activate() -> void:
	for actionID in actionIDs:
		if not room.actionsDict.has(actionID):
			push_warning("Interactable's action not found in parent room. Action: " + actionID + ", removing.")
			queue_free()
			return

	currentActionID = actionIDs[0]
	name = room.roomName + "_" + uniqueName as String
	InputManager.addObjectToContext("Exploring",name, self)


func setInput(set:bool) -> void:
	if set: mouse_filter = Control.MOUSE_FILTER_STOP
	else: mouse_filter = Control.MOUSE_FILTER_IGNORE

func resizeRef() -> void:
	get_node("ReferenceRect").rect_size = rect_size


func clicked(event:InputEvent) -> void:
	if event.is_action_pressed("ui_select"):
		var action:Array = room.actionsDict.get(currentActionID)
		match action.size():
			2:
				var outputNumber:int = actionCondition(action[0])
				for subAction in action[1][outputNumber]:
					match subAction[0]:
						"ShowText": 
							textAction(subAction[1][0])
							yield(room.mainTextDisplayRef,"done_displaying")
						"FindItem": findItemAction(subAction[1][0])
						"RemoveItem": removeItemAction(subAction[1][0])
						_: push_error("Action not defined: " + subAction[1][0])
			3: 
				match action[1]:
					"ShowText": 
						textAction(action[2][0])
						yield(room.mainTextDisplayRef,"done_displaying")
					"FindItem": findItemAction(action[2][0])
					"RemoveItem": removeItemAction(action[2][0])
					_: push_error("Action not defined: " + action[1])
		
		if oneShot: 
			InputManager.removeObjectFromContext("Exploring",name)
			self.queue_free()

func actionCondition(condition:Array) -> int:
	match condition[0]:
		"ItemRequiered":
			if room.mainInventoryRef.selectedItem != null and room.mainInventoryRef.selectedItem.name == condition[1][0]:
				if switchMode != "None": currentActionID = actionIDs[1]
				return 0
			else: return 1
		"None": return 0
		_: 
			return -1

func textAction(textID:String) -> void:
	if not room.textDict.has(textID):
		push_error("Text ID " + textID + " not found.")
		return
	room.mainTextDisplayRef.visible = true
	room.mainTextDisplayRef.setText(room.textDict[textID])
	InputManager.setActiveContext("ReadingText")

# ID:[TextID, ExtraArguments]
# ItemID/Name:[AtlasID]
func findItemAction(itemID:String) -> void:
	room.mainInventoryRef.addItem(room.itemsDict[itemID], itemID)

func removeItemAction(itemName:String) -> void:
	room.mainInventoryRef.removeItem(itemName)
