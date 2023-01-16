extends Object
class_name Context

#### USAGE ####
# An object that will be added to the context must have two functions:

# 1)  func processInput(event:InputEvent) -> void
# This optional function processes all the keyboard, buttons, controller input refering to actions
# Gui input is written in another function called by the gui input signal

# 2) func func setInput(set:bool) -> void
# This one enables and disables the gui input when entering or exiting the context

var contextName:String = "NotSet"
var dictOfFunctions:Dictionary setget doNothing

# warning-ignore:unused_argument
func doNothing(dict:Dictionary) -> void: return

func _init(name:String):
	contextName = name


func addObject(name:String, obj:Object) -> bool:
	if dictOfFunctions.has(name): 
		push_error("The Object " + name + " already exists in context" + contextName)
		return false
	
	dictOfFunctions[name] = obj
	return true


func removeObject(name:String) -> bool:
	if not dictOfFunctions.has(name):
		push_warning("The Object " + name + " does not exist in context" + contextName)
		return false
	
# warning-ignore:return_value_discarded
	dictOfFunctions.erase(name)
	return true

func processContext(event:InputEvent) -> void:
	for obj in dictOfFunctions.values():
		if obj == null: push_error("Object " + obj + " is null in context " + contextName)
		if not obj.has_method("processInput"): continue
		obj.processInput(event)


func setContext(set:bool) -> void:
	for obj in dictOfFunctions.values():
		if obj == null: push_error("Object " + obj + " is null in context " + contextName)
		obj.setInput(set)
