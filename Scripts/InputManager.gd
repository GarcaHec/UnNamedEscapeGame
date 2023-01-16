extends Node

var contexts = {} setget doNothingDict
var activeContext:Context = null setget doNothing
var previousContext:Context = null setget doNothing

# warning-ignore:unused_argument
func doNothingDict(dict:Dictionary) -> void: return
# warning-ignore:unused_argument
func doNothing(context:Context) -> void: return

func _ready() -> void:
#	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	pass

func addObjectToContext(contextName:String, objName:String, obj:Object) -> void:
	if not contexts.has(contextName):
		var newContext:Context = Context.new(contextName)
		contexts[contextName] = newContext
	
	var didItWork:bool = contexts[contextName].addObject(objName, obj)
	if activeContext != null and contexts[contextName].contextName == activeContext.contextName: obj.setInput(true)


func removeObjectFromContext(contextName:String, objName:String) -> void:
	contexts[contextName].removeObject(objName)

func _input(event:InputEvent) -> void:
	if activeContext == null: return
	activeContext.processContext(event)


func setActiveContext(name:String) -> void:
	if not contexts.has(name):
		push_warning("Context " + name + " does not exist")
		return

	if activeContext != null:
		activeContext.setContext(false)
		previousContext = activeContext

	activeContext = contexts[name]
	activeContext.setContext(true)


func returnToPreviousContext() -> void:
	if previousContext == null:
		push_warning("Previous context is null")
		return
	
	activeContext.setContext(false)
	var tmpContext:Context = activeContext
	activeContext = previousContext
	previousContext = tmpContext
	activeContext.setContext(true)


func disableActiveContext() -> void:
	activeContext.setContext(false)
	previousContext = activeContext
	activeContext = null
