@tool
class_name ChoiceEditPanel
extends Control

@export var index: int = 0:
	set(value): 
		if choice:
			index = clampi(value, 0, choice.options.size() - 1)
		else:
			index = value
		update_ui_elements()

@export var item_angle_delta: float = 5.0:
	set(value): item_angle_delta = value; update_ui_elements()
@export var item_pivot_offset: Vector2 = Vector2(-500.0, 15.0):
	set(value): item_pivot_offset = value; update_ui_elements()
@export var arrow_offset: Vector2 = Vector2(15.0, 15.0):
	set(value): arrow_offset = value; update_ui_elements()
	
@export var choice_origin: Control
@export var choice_container: Control:
	set(value): choice_container = value; update_ui_elements()
@export var left_arrow: Node2D:
	set(value): left_arrow = value; update_ui_elements()
@export var right_arrow: Node2D:
	set(value): right_arrow = value; update_ui_elements()

@export var choice_option_item_scene: PackedScene

## Index of the item that is currently focused,
## where the arrow is pointed at and the item that will be selected for the choice 
## on the next click/key press

@export var scroll_speed: float = 12.0

## Index smoothed over time to animate towards the current index.
var visual_index: float = 0

## Choice that an option is currently being chosen from
var choice: ArticleChoice

## Emitted when the user confirms an option choice via their ui controls
signal item_selected(choice: ArticleChoice, index: int)

func _ready() -> void:
	update_ui_elements()
	choice_container.child_order_changed.connect(_on_child_order_changed)
	
	if not Engine.is_editor_hint():
		hide()

func _process(delta: float) -> void:
	visual_index = move_toward(visual_index, index, scroll_speed * delta)
	
	for item_index: int in choice_container.get_child_count():
		var item: Control = choice_container.get_child(item_index)
		var item_visual_index: float = item_index - visual_index
		item.rotation_degrees = item_visual_index * item_angle_delta
		item.pivot_offset = item_pivot_offset

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("ui_accept"):
			select_current_item()
		elif event.is_action_pressed("ui_up"):
			index -= 1
		elif event.is_action_pressed("ui_down"):
			index += 1

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			index -= 1
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			index += 1

@warning_ignore("shadowed_variable")
func setup(choice: ArticleChoice, global_pos: Vector2) -> void:
	self.choice = choice
	
	choice_origin.global_position = global_pos
	
	for child: Node in choice_container.get_children():
		child.queue_free()
		
	index = choice.chosen_option
	visual_index = index
		
	for option_index: int in choice.options.size():
		var choice_option_item := choice_option_item_scene.instantiate() as ArticleChoiceOptionItemUI
		choice_option_item.setup(choice, option_index)
		choice_option_item.pressed.connect(_on_item_pressed.bind(choice_option_item))
		choice_container.add_child(choice_option_item)
		
	await get_tree().process_frame
	update_ui_elements()

func select_current_item() -> void:
	hide()
	choice.chosen_option = index
	item_selected.emit(choice, index)

func _on_child_order_changed() -> void:
	update_ui_elements()

func update_ui_elements() -> void:
	if not choice_container:
		return
	
	var max_width: float = 0.0
	for item_index: int in choice_container.get_child_count():
		var item: Control = choice_container.get_child(item_index)
		max_width = maxf(max_width, item.size.x)
		
	if left_arrow:	
		left_arrow.position = Vector2(-arrow_offset.x, arrow_offset.y - 30.0)
	if right_arrow:
		right_arrow.position = Vector2(max_width + arrow_offset.x, arrow_offset.y - 30.0)

func _on_item_pressed(item: ArticleChoiceOptionItemUI) -> void:
	hide()
	choice.chosen_option = item.index
	item_selected.emit(item.choice, item.index)
