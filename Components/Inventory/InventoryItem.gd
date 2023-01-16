extends TextureRect

signal item_selected(item)

onready var sprite:TextureRect = $ItemSprite
onready var animator:Tween = $Animator

export(float) var animationTime = 0.5

var ID:int = -1
var selected:bool = false

func init(newID:int, newName:String, target:Object) -> void:
	if newID < 0: 
		push_warning("Tried to create an item with negative ID."); return 
	elif newID >= ResourcesManager.maxItems: 
		push_warning("Item ID out of range."); return
	
	ID = newID
	(sprite.texture as AtlasTexture).region.position = Vector2(ID/(ResourcesManager.itemsMatrix.x as int), ID%(ResourcesManager.itemsMatrix.x as int))*180
	
	name = newName
	connect("item_selected", target, "itemSelected")


func setInput(set:bool) -> void:
	if set: 
		mouse_filter = Control.MOUSE_FILTER_STOP
	else: 
		mouse_filter = Control.MOUSE_FILTER_IGNORE


func hovered() -> void:
	if !selected:
		animator.stop_all()
		animator.interpolate_property(sprite, "rect_scale" , null, Vector2.ONE*0.7, animationTime,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
		animator.start()


func unhovered() -> void:
	if !selected:
		animator.stop_all()
		animator.interpolate_property(sprite, "rect_scale" , null, Vector2.ONE*0.5, animationTime,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
		animator.start()


func clicked(event:InputEvent) -> void:
	if event.is_action_pressed("ui_select"):
		if !selected:
			(texture as AtlasTexture).region.position = Vector2(480,720)
			emit_signal("item_selected", self)
			selected = true
		else: 
			emit_signal("item_selected", null)


func unselected() -> void:
	(texture as AtlasTexture).region.position = Vector2(480,480)
	selected = false
	if !(Rect2(Vector2.ZERO, rect_size).has_point(get_local_mouse_position())): 
		unhovered()
