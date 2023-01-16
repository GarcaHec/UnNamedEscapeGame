class_name Inventory
extends Node

onready var mainPanel:Control = $MainButton
onready var anchor:Control = $Anchor
onready var panelsContainer:Control = $Anchor/PanelsContainer
onready var itemsContainer:Control = $Anchor/ItemsContainer
onready var fillPanels:Array = [$Anchor/PanelsContainer/Fill]
onready var animator:Tween = $Animator

var visible:bool = true
var finalPos:Vector2

var nRows:int = 0 
var nColumns:int = 1

var itemTemplate:Resource = preload("res://Components/Inventory/InventoryItem.tscn")
var itemsList:Array = []
var selectedItem:Control = null

export(Vector2) var offset
export (float) var animationTime = 1.0
export(int, "Left", "Right") var hideDirection
export(int) var maxRows

func _ready() -> void:
	InputManager.addObjectToContext("Exploring","Inventory",self)
	
	resize()
	if not hideDirection: anchor.rect_position = Vector2(offset.x, offset.y)
	else: anchor.rect_position = Vector2(-anchor.rect_size.x - offset.x + ResourcesManager.windowWidth, offset.y)
	
	animator.connect("tween_all_completed", self, "de_activateItems", [true])

func de_activateItems(set:bool) -> void:
	for item in itemsList: item.setInput(set)

func setInput(set:bool) -> void:
	set_process_input(set)
	for item in itemsList: item.setInput(set)
	if set: 
		mainPanel.mouse_filter = Control.MOUSE_FILTER_STOP
	else: 
		mainPanel.mouse_filter = Control.MOUSE_FILTER_IGNORE


func panelClicked(event:InputEvent) -> void:
	if event.is_action_pressed("ui_select") and !animator.is_active(): toggle_display()

func _input(event:InputEvent) -> void:
	if event.is_action_pressed("open_inventory") and !animator.is_active(): toggle_display()

func toggle_display() -> void:
	if visible: 
		finalPos = Vector2(anchor.rect_size.x*(hideDirection - 1) + offset.x*(2*hideDirection - 1) + hideDirection*ResourcesManager.windowWidth, offset.y)
		de_activateItems(false)
	else: finalPos = Vector2(offset.x*(1 - 2*hideDirection) + hideDirection*(ResourcesManager.windowWidth - anchor.rect_size.x), offset.y)
	animator.interpolate_property(anchor, "rect_position" , null, finalPos, animationTime,Tween.TRANS_EXPO,Tween.EASE_IN_OUT)
	animator.start()
	visible = !visible

func setItems(set:bool) -> void:
	for item in itemsList: item.setInput(set)

func resize() -> void:
	while fillPanels.size() < nColumns - 1:
		var fillDuplicate:Control = fillPanels[0].duplicate()
		panelsContainer.add_child_below_node(fillPanels[-1],fillDuplicate)
		fillPanels.append(fillDuplicate)
	
	for iFill in range(0,fillPanels.size()):
		if iFill >= nColumns - 1: fillPanels[iFill].visible = false
		else: fillPanels[iFill].visible = true
	
	anchor.rect_size = panelsContainer.get_minimum_size()


func setNRows(rows:int) -> void:
	nRows = rows

func setNColumns(columns:int) -> void:
	nColumns = columns

func itemSelected(item:Control) -> void:
	if selectedItem != null: selectedItem.unselected()
	selectedItem = item

func addItem(ID:int, itemName:String) -> void:
	for item in itemsList:
		if item.name == itemName: 
			push_warning("Trying to add a duplicate of the item " + itemName + " ID = " + (ID as String))
			return  
	itemsList.append(itemTemplate.instance())
	
	itemsContainer.add_child(itemsList[-1])
	itemsList[-1].init(ID, itemName, self)
	itemsList[-1].mouse_filter = mainPanel.mouse_filter


func removeItem(itemNameToRemove:String) -> void:
	for item in itemsList:
		if item.name == itemNameToRemove:
			itemsList.erase(item)
			item.queue_free()
			return
	push_error("No item found to remove. Name: " + itemNameToRemove)
