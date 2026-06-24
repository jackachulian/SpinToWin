class_name ArticleUI
extends AnimatableControl

@export var header_rtl: ArticleTextRTL
@export var body_rtl: ArticleTextRTL

@export var real_event_panel: Control
@export var article_panel: Control
@export var submit_article_panel: Control

@export var real_event_label: Label

#@export var article_texture_rect: TextureRect
@export var blur_material: ShaderMaterial
@export var choice_edit_blur_radius: float = 0.375

@export var desired_perception_ui: DesiredPerceptionUI
@export var choice_edit_panel: ChoiceEditPanel

func _ready() -> void:
	blur_material.set_shader_parameter("blur_radius", 0.00)
	choice_edit_panel.item_selected.connect(_on_choice_edit_panel_item_selected)
	
	header_rtl.choice_clicked.connect(_on_choice_clicked)
	body_rtl.choice_clicked.connect(_on_choice_clicked)

func setup(article: ArticleLevel) -> void:
	header_rtl.setup([article.header])
	body_rtl.setup(article.body)
	
	real_event_label.text = article.real_event
	desired_perception_ui.setup()
	
func _on_choice_clicked(choice: ArticleChoice, global_pos: Vector2, sentence_start: String) -> void:
	choice_edit_panel.setup(choice, global_pos, sentence_start)
	choice_edit_panel.show()
	blur_material.set_shader_parameter("blur_radius", choice_edit_blur_radius)

func _on_choice_edit_panel_item_selected(_choice: ArticleChoice, _index: int) -> void:
	blur_material.set_shader_parameter("blur_radius", 0.00)
	header_rtl.reset_editing_text()
	body_rtl.reset_editing_text()
	
	
func _on_submit_button_pressed() -> void:
	MainGame.instance.player_data.apply_changes_from_article(MainGame.instance.event_manager.article)
	MainGame.instance.event_manager.progress_event()

	
const ANIM_CLEAR_COLOR := Color(1,1,1,0)
const REAL_EVENT_ANIM_OFFSET := Vector2(-100, 0)
const DESIRED_PERCEPTION_ANIM_OFFSET := Vector2(100, 0)
const SUBMIT_ANIM_OFFSET := Vector2(100, 0)
const ANIM_IN_DURATION := 0.75
const ANIM_OUT_DURATION := 0.6
const SUBMIT_ANIM_IN_DURATION := 1.0
const SUBMIT_ANIM_OUT_DURATION := 0.8

func animate_in() -> void:
	setup(MainGame.instance.event_manager.article)
	
	await get_tree().process_frame

	real_event_panel.offset_transform_enabled = true
	real_event_panel.offset_transform_position = REAL_EVENT_ANIM_OFFSET
	real_event_panel.modulate = ANIM_CLEAR_COLOR
	
	desired_perception_ui.offset_transform_enabled = true
	desired_perception_ui.offset_transform_position = DESIRED_PERCEPTION_ANIM_OFFSET
	desired_perception_ui.modulate = ANIM_CLEAR_COLOR
	
	article_panel.offset_transform_enabled = true
	article_panel.offset_transform_scale = Vector2.ZERO
	article_panel.modulate = ANIM_CLEAR_COLOR
	
	submit_article_panel.offset_transform_enabled = true
	submit_article_panel.offset_transform_position = SUBMIT_ANIM_OFFSET
	submit_article_panel.modulate = ANIM_CLEAR_COLOR

	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT).set_parallel(true)
	
	tween.tween_property(real_event_panel, "offset_transform_position", Vector2.ZERO, ANIM_IN_DURATION)
	tween.tween_property(real_event_panel, "modulate", Color.WHITE, ANIM_IN_DURATION)
	
	tween.tween_property(desired_perception_ui, "offset_transform_position", Vector2.ZERO, ANIM_IN_DURATION)
	tween.tween_property(desired_perception_ui, "modulate", Color.WHITE, ANIM_IN_DURATION)
	
	tween.tween_property(article_panel, "offset_transform_scale", Vector2.ONE, ANIM_IN_DURATION)
	tween.tween_property(article_panel, "modulate", Color.WHITE, ANIM_IN_DURATION)
	
	tween.tween_property(submit_article_panel, "offset_transform_position", Vector2.ZERO, SUBMIT_ANIM_IN_DURATION)
	tween.tween_property(submit_article_panel, "modulate", Color.WHITE, SUBMIT_ANIM_IN_DURATION)
	
	await tween.finished
	
func animate_out() -> void:
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT).set_parallel(true)
	
	tween.tween_property(real_event_panel, "offset_transform_position", REAL_EVENT_ANIM_OFFSET, ANIM_OUT_DURATION)
	tween.tween_property(real_event_panel, "modulate", ANIM_CLEAR_COLOR, ANIM_OUT_DURATION)
	
	tween.tween_property(desired_perception_ui, "offset_transform_position", DESIRED_PERCEPTION_ANIM_OFFSET, ANIM_OUT_DURATION)
	tween.tween_property(desired_perception_ui, "modulate", ANIM_CLEAR_COLOR, ANIM_OUT_DURATION)
	
	tween.tween_property(article_panel, "offset_transform_scale", Vector2.ZERO, ANIM_OUT_DURATION)
	tween.tween_property(article_panel, "modulate", ANIM_CLEAR_COLOR, ANIM_OUT_DURATION)
	
	tween.tween_property(submit_article_panel, "offset_transform_position", SUBMIT_ANIM_OFFSET, SUBMIT_ANIM_OUT_DURATION)
	tween.tween_property(submit_article_panel, "modulate", ANIM_CLEAR_COLOR, SUBMIT_ANIM_OUT_DURATION)
	
	await tween.finished
