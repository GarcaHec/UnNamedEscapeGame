extends Node

var singleCameraMode:bool = false setget changeCameraMode

var mainScene:Node

var roomsFolder:String = "res://Components/Rooms/"
var firstRoom:String = "LockerRoom"

var loadedRooms:Dictionary = {}
var currRoom:Room = null

func changeCameraMode(isSingleCamera:bool) -> void:
	singleCameraMode = isSingleCamera
	if currRoom != null: currRoom.setCameraMode(singleCameraMode)

func loadRoom(room:String) -> void:
	var roomDict:Dictionary
	ResourcesManager.parseXMLRoomLoader(roomsFolder + room + "/RoomLoad.xml", roomDict)
	
	var roomLoaded:bool = false
	var neighbourLoaded:Array = []
	
	for roomInMemory in loadedRooms:
		if roomInMemory != room and !roomDict[room].has(roomInMemory):
			roomInMemory.queue_free()
			loadedRooms.erase(roomInMemory)
		elif roomInMemory == room: roomLoaded = true
		else: neighbourLoaded.append(roomInMemory)
	
	if !roomLoaded: loadedRooms[room] = load(roomsFolder + room + "/" + room + ".tscn").instance()
	for neighbour in roomDict[room]:
		if neighbourLoaded.has(neighbour): continue
		loadedRooms[neighbour] = load(roomsFolder + neighbour + "/" + neighbour + ".tscn").instance()
