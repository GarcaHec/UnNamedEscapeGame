class_name TextDisplay
extends Control

signal done_displaying

enum speedValues{INSTANT, SLOW, FAST = 3}

const internalSpeed:float = 0.2
var charCounter:float = 0

export(int, "Instant", "Slow", "Fast") var textSpeed:int setget changeSpeed
onready var text:RichTextLabel = $Text
onready var endTextLabel:Node = $EndTextLabel

func _ready() -> void:
	InputManager.addObjectToContext("ReadingText", "TextDisplay", self)

func processInput(event:InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if text.percent_visible < 1: 
			text.percent_visible = 1 
		else:
			visible = false
			InputManager.returnToPreviousContext()
			emit_signal("done_displaying")

# warning-ignore:unused_argument
func setInput(set:bool) -> void: return

func _physics_process(_delta:float) -> void:
	if text.percent_visible < 1 and text.get_total_character_count() > 0:
		charCounter += internalSpeed*textSpeed
		text.percent_visible = charCounter/(text.get_total_character_count() as float)
	elif text.percent_visible >= 1:
		endTextLabel.visible = true
		set_physics_process(false)

func setText(newText:String) -> void:
	if(textSpeed == speedValues.INSTANT): 
		endTextLabel.visible = true
		text.percent_visible = 1
	else: 
		set_physics_process(true)
		endTextLabel.visible = false
		text.percent_visible = 0
		charCounter = 0
	text.bbcode_text = newText

func changeSpeed(newSpeed:int) -> void:
	match newSpeed:
		0:
			textSpeed = speedValues.INSTANT
			set_physics_process(false)
			if text != null: 
				endTextLabel.visible = true
				text.percent_visible = 1
		1,2:
			textSpeed = speedValues[speedValues.keys()[newSpeed]]
			set_physics_process(true)
			if text != null:
				endTextLabel.visible = false 
				text.percent_visible = 0
			charCounter = 0
		_: push_warning("newSpeed is not a valid value.")
