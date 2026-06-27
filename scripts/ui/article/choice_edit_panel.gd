@tool
class_name ChoiceEditPanel
extends Control

@export var index: int = 0:
	set(value): 
		if choice:
			var new_index := clampi(value, 0, choice.options.size() - 1)
			if new_index != index:
				index = new_index
				choice_anim_start_index = visual_index
				choice_anim_elapsed_time = 0
				MainGame.instance.audio_manager.play_audio_by_id("article_choice_select")
		else:
			index = value
		update_ui_elements()

@export var item_angle_delta: float = 5.0:
	set(value): item_angle_delta = value; update_ui_elements()
@export var item_pivot_offset: Vector2 = Vector2(-500.0, 15.0):
	set(value): item_pivot_offset = value; update_ui_elements()
@export var arrow_offset: Vector2 = Vector2(15.0, 15.0):
	set(value): arrow_offset = value; update_ui_elements()
@export var side_margin: float = 120.0
	
@export var choice_origin: Control
@export var sentence_start_rtl: RichTextLabel
@export var choice_container: Control:
	set(value): choice_container = value; update_ui_elements()
@export var choice_anim_curve: Curve
@export var choice_anim_duration: float = 0.25
@export var choice_alpha_falloff: float = 0.25
	
@export var normal_label_settings: LabelSettings:
	set(value): normal_label_settings = value; update_ui_elements()
@export var focused_label_settings: LabelSettings:
	set(value): focused_label_settings = value; update_ui_elements()
@export var lie_focused_label_settings: LabelSettings:
	set(value): lie_focused_label_settings = value; update_ui_elements()
	
@export var left_arrow: Node2D:
	set(value): left_arrow = value; update_ui_elements()
@export var right_arrow: Node2D:
	set(value): right_arrow = value; update_ui_elements()

@export var choice_option_item_scene: PackedScene

## Index of the item that is currently focused,
## where the arrow is pointed at and the item that will be selected for the choice 
## on the next click/key press

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

const SNAP_WEIGHT: float = 10.0

var choice_anim_start_index: float = 0.0
var choice_anim_elapsed_time: float = 0.0

func _process(delta: float) -> void:
	choice_anim_elapsed_time += delta
	
	var t = clamp(choice_anim_elapsed_time / choice_anim_duration, 0.0, 1.0)
	var curve_sample := choice_anim_curve.sample(t)
	visual_index = lerpf(choice_anim_start_index, float(index), curve_sample)
	
	for item_index: int in choice_container.get_child_count():
		var item: Control = choice_container.get_child(item_index)
		var item_visual_index: float = item_index - visual_index
		item.rotation_degrees = item_visual_index * item_angle_delta
		item.pivot_offset = item_pivot_offset
		item.modulate = Color(1,1,1,1 - absf(float(item_index) - visual_index)*choice_alpha_falloff)

func _input(event: InputEvent) -> void:
	if !choice: return
	if event is InputEventKey:
		if event.is_action_pressed("ui_accept"):
			select_current_item()
		elif event.is_action_pressed("ui_up"):
			index -= 1
		elif event.is_action_pressed("ui_down"):
			index += 1

func _gui_input(event: InputEvent) -> void:
	if !choice: return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			select_current_item()
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			index -= 1
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			index += 1

@warning_ignore("shadowed_variable")
func setup(choice: ArticleChoice, global_pos: Vector2, sentence_start: String) -> void:
	self.choice = choice
	
	choice_origin.global_position = global_pos
	
	sentence_start_rtl.text = "[bgcolor=#dbdbd7]"+sentence_start+"[/bgcolor]"
	sentence_start_rtl.update_minimum_size()
	
	for child: Node in choice_container.get_children():
		child.queue_free()
		
	index = choice.chosen_option
	choice_anim_start_index = choice.chosen_option
	visual_index = choice.chosen_option
		
	for option_index: int in choice.options.size():
		var choice_option_item := choice_option_item_scene.instantiate() as ArticleChoiceOptionItemUI
		choice_option_item.setup(choice, option_index)
		choice_option_item.pressed.connect(_on_item_pressed.bind(choice_option_item))
		choice_container.add_child(choice_option_item)
		
	await get_tree().process_frame
		
	var max_width: float = 0.0
	var max_height: float = 0.0
	for item_index: int in choice_container.get_child_count():
		var item: Control = choice_container.get_child(item_index)
		item.update_minimum_size()
		max_width = maxf(max_width, item.size.x)
		max_height = maxf(max_height, item.size.y)
		
	var viewport_rect := get_viewport().get_visible_rect()
	var viewport_size: Vector2 = viewport_rect.size
		
	var start_global_point := sentence_start_rtl.global_position
	if start_global_point.x < viewport_rect.position.x + side_margin:
		choice_origin.global_position.x = viewport_rect.position.x + sentence_start_rtl.size.x + side_margin
		
	var end_local_point := choice_origin.position + Vector2(max_width, 0)
	var end_global_point := get_global_transform() * end_local_point
	if end_global_point.x > viewport_size.x - side_margin:
		choice_origin.global_position.x = viewport_size.x - side_margin - max_width
		
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
	var max_height: float = 0.0
	for item_index: int in choice_container.get_child_count():
		var item: ArticleChoiceOptionItemUI = choice_container.get_child(item_index)
		max_width = maxf(max_width, item.size.x)
		max_height = maxf(max_height, item.size.y)
		
		if item and item.choice:
			var option: ArticleChoiceOption = item.choice.options[item.index]
			if index == item_index:
				item.label.label_settings = lie_focused_label_settings if option.is_lie else focused_label_settings
				item.lie_control.visible = option.is_lie
			else:
				item.label.label_settings = normal_label_settings
				item.lie_control.visible = false
		
	if left_arrow:	
		left_arrow.position = Vector2(-arrow_offset.x, arrow_offset.y - max_height)
	if right_arrow:
		right_arrow.position = Vector2(max_width + arrow_offset.x, arrow_offset.y - max_height)

func _on_item_pressed(item: ArticleChoiceOptionItemUI) -> void:
	hide()
	choice.chosen_option = item.index
	item_selected.emit(item.choice, item.index)
