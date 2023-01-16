extends Control
class_name Room

export var roomName:String = ""
export(String, DIR) var loadFilesPath:String

onready var containers:Array = [$VBC/HBC_Top, $VBC/HBC_Bottom]
onready var views:Array = [$VBC/HBC_Top/Front, $VBC/HBC_Top/Right, $VBC/HBC_Bottom/Back, $VBC/HBC_Bottom/Left]

var textDict:Dictionary = {}
var itemsDict:Dictionary = {}
var actionsDict:Dictionary = {}

var currentView:int = 0
var mainTextDisplayRef:Object
var mainInventoryRef:Object

var interactablesArray:Array = []

func _ready() -> void:
	mainTextDisplayRef = get_parent().mainTextDisplay
	mainInventoryRef = get_parent().mainInventory
	
	if(loadFilesPath == ""): push_error("No load files for the room " + roomName)
	ResourcesManager.parseXMLRoomFile(loadFilesPath + "/RoomActions.xml", actionsDict)
	ResourcesManager.parseXMLRoomFile(loadFilesPath + "/RoomTexts.xml", textDict)
	ResourcesManager.parseXMLRoomFile(loadFilesPath + "/RoomItems.xml", itemsDict)

	for element in interactablesArray: element.activate()
	setCameraMode(RoomsManager.singleCameraMode)
#warning-ignore:return_value_discarded
#	RoomsManager.connect("cameramode_changed",self,"setCameraMode")


func setCameraMode(isSingleCamera:bool) -> void:
	if isSingleCamera:
		if currentView == -1: currentView = 0
		rect_scale = Vector2.ONE*2
# warning-ignore:integer_division
		rect_position = -(containers[currentView/2].rect_position + views[currentView].rect_position)*2
		InputManager.addObjectToContext("Exploring", roomName, self)
	else:
		currentView = -1
		rect_position = Vector2.ZERO
		rect_scale = Vector2.ONE
		InputManager.removeObjectFromContext("Exploring", roomName)

func setInput(_set:bool) -> void: return

func processInput(event:InputEvent) -> void:
	if event.is_action_pressed("turn_right"):
		currentView += 1
		if currentView > 3: currentView = 0
# warning-ignore:integer_division
		rect_position = -(containers[currentView/2].rect_position + views[currentView].rect_position)*2
	elif event.is_action_pressed("turn_left"):
		currentView -= 1
		if currentView < 0: currentView = 3
# warning-ignore:integer_division
		rect_position = -(containers[currentView/2].rect_position + views[currentView].rect_position)*2

