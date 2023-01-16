extends Node

var textDisplayTemplate:Resource = preload("res://Components/TextDisplay.tscn")
var inventoryTemplate:Resource = preload("res://Components/Inventory/Inventory.tscn")

var mainTextDisplay:TextDisplay = textDisplayTemplate.instance()
var mainInventory:Inventory = inventoryTemplate.instance()

func _ready() -> void:
	RoomsManager.mainScene = self
	add_child(mainInventory)
	add_child(mainTextDisplay)
	(mainTextDisplay as Control).rect_position = Vector2(ResourcesManager.currentWidth/4, ResourcesManager.currentHeight*3/4)
	InputManager.setActiveContext("Exploring")
	RoomsManager.loadRoom(RoomsManager.firstRoom)
	RoomsManager.currRoom = RoomsManager.loadedRooms[RoomsManager.firstRoom]
	add_child(RoomsManager.currRoom)
	move_child(RoomsManager.currRoom, 0)
	InputManager.setActiveContext("Exploring")
