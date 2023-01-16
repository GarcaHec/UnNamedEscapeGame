class_name Transformable
extends TextureRect

signal moved
signal rotated

export(int) var textureID:int = 0 setget setTextureID
export(Vector2) var atlasMatrix:Vector2 = Vector2.ZERO
export(String, "Move", "Rotate", "Depth") var mode:String = "Move"

export var constraints:Rect2

var mousePosInClick:Vector2
var prevRotation:float

func _ready() -> void:
	rect_pivot_offset = rect_size/2
	
	set_physics_process(false)

func setTextureID(newTextureID:int) -> void:
	if newTextureID < 0: textureID = 0
	
	textureID = newTextureID
	(texture as AtlasTexture).region.position = Vector2(textureID/(atlasMatrix.x as int), textureID%(atlasMatrix.x as int))


func _physics_process(delta) -> void:
	var mousePos:Vector2 = get_global_mouse_position()
	
	match mode:
		"Move": 
			move(mousePos - rect_size/2)
		"Rotate":
			var addRotation:float = (mousePos - rect_position - rect_size/2).angle_to(mousePosInClick - rect_position - rect_size/2)
			set_rotation(prevRotation - addRotation)


func move(newPosition:Vector2) -> void:
	rect_position = newPosition
	checkConstraints()
	emit_signal("moved")

func rotate(newRotation:float) -> void:
	set_rotation(newRotation)

func checkConstraints() -> void:
	if constraints.size != Vector2.ZERO:
		if rect_position.x < constraints.position.x: rect_position.x = constraints.position.x 
		if rect_position.x > constraints.end.x: rect_position.x = constraints.end.x
		if rect_position.y < constraints.position.y: rect_position.y = constraints.position.y
		if rect_position.y > constraints.end.x: rect_position.y = constraints.end.y

func clicked(event:InputEvent) -> void:
	if event.is_action_pressed("ui_select"):
		mousePosInClick = get_global_mouse_position()
		prevRotation = get_rotation()
		set_physics_process(true)
	if event.is_action_released("ui_select"):
		set_physics_process(false)
