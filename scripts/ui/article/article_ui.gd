class_name ArticleUI
extends AnimatableControl

@export var header_rtl: ArticleTextRTL
@export var body_rtl: ArticleTextRTL

@export var spin_the_article_label: Label
@export var real_event_panel: Control
@export var article_panel: Control
@export var submit_article_panel: Control

@export var real_event_label: Label

#@export var article_texture_rect: TextureRect
@export var blur_material: ShaderMaterial
@export var choice_edit_blur_radius: float = 0.375

@export var desired_perception_ui: DesiredPerceptionUI
@export var choice_edit_panel: ChoiceEditPanel

@onready var submit_button: Button = $SubmitArticle/MarginContainer/SubmitButton

@onready var input_blocker: Control = $InputBlocker

enum TutorialState {
	NONE,
	CLICK_CHOICE,
	CONFIRM_CHOICE_OPTION,
	CLICK_DESIRED_PERCEPTIONS
}
## only used in the tutorial
var tutorial_state: TutorialState = TutorialState.NONE

func _ready() -> void:
	blur_material.set_shader_parameter("blur_radius", 0.00)
	choice_edit_panel.item_selected.connect(_on_choice_edit_panel_item_selected)
	
	header_rtl.choice_clicked.connect(_on_choice_clicked)
	body_rtl.choice_clicked.connect(_on_choice_clicked)

func set_dialogue_blocks_inputs(blocks_inputs: bool) -> void:
	if blocks_inputs:
		MainGame.instance.dialogue_balloon.will_block_other_input = true
		MainGame.instance.dialogue_balloon.balloon.mouse_filter = Control.MOUSE_FILTER_STOP
		MainGame.instance.dialogue_balloon.can_advance_via_input = true
	else:
		MainGame.instance.dialogue_balloon.will_block_other_input = false
		MainGame.instance.dialogue_balloon.balloon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		MainGame.instance.dialogue_balloon.can_advance_via_input = false

func wait_for_article_choice_click() -> void:
	tutorial_state = TutorialState.CLICK_CHOICE
	MainGame.instance.dialogue_ui.show_tutorial_focus_global_rect(article_panel.get_global_rect())
	set_dialogue_blocks_inputs(false)

func wait_for_article_choice_confirm() -> void:
	tutorial_state = TutorialState.CONFIRM_CHOICE_OPTION
	set_dialogue_blocks_inputs(false)
	
func wait_for_desired_perception_click() -> void:
	tutorial_state = TutorialState.CLICK_DESIRED_PERCEPTIONS
	MainGame.instance.dialogue_ui.show_tutorial_focus_global_rect(desired_perception_ui.get_global_rect())
	set_dialogue_blocks_inputs(false)
	
func disable_submit_button() -> void:
	submit_button.disabled = true
	
func enable_submit_button() -> void:
	submit_button.disabled = false

func setup(article: ArticleLevel) -> void:
	input_blocker.hide()
	header_rtl.setup([article.header])
	body_rtl.setup(article.body)
	
	real_event_label.text = article.real_event
	desired_perception_ui.setup()
	
	if not MainGame.instance.event_manager.event_data.article_dialogue_path.is_empty():
		var article_dialogue: DialogueResource = ResourceLoader.load(MainGame.instance.event_manager.event_data.article_dialogue_path)
		print("Playing article dialogue")
		#await get_tree().create_timer(1.0).timeout
		input_blocker.show()
		MainGame.instance.dialogue_layer.open()
		DialogueLoader.run_dialogue(article_dialogue)
		set_dialogue_blocks_inputs(true)
		disable_submit_button()
		
		while MainGame.instance.dialogue_layer.animating:
			await MainGame.instance.dialogue_layer.animating_finished
		input_blocker.hide()

	
	
func _on_choice_clicked(choice: ArticleChoice, global_pos: Vector2, sentence_start: String) -> void:
	choice_edit_panel.setup(choice, global_pos, sentence_start)
	choice_edit_panel.show()
	MainGame.instance.audio_manager.play_audio_by_id("article_choice_open")
	blur_material.set_shader_parameter("blur_radius", choice_edit_blur_radius)
	
	if tutorial_state == TutorialState.CLICK_CHOICE:
		tutorial_state = ArticleUI.TutorialState.NONE
		set_dialogue_blocks_inputs(true)
		MainGame.instance.dialogue_balloon.advance()
		MainGame.instance.dialogue_ui.hide_tutorial_rect()
		

func _on_choice_edit_panel_item_selected(_choice: ArticleChoice, _index: int) -> void:
	MainGame.instance.audio_manager.play_audio_by_id("article_choice_confirm", "SFX", 1.0)
	blur_material.set_shader_parameter("blur_radius", 0.00)
	header_rtl.reset_editing_text()
	body_rtl.reset_editing_text()
	
	if tutorial_state == TutorialState.CONFIRM_CHOICE_OPTION:
		tutorial_state = ArticleUI.TutorialState.NONE
		set_dialogue_blocks_inputs(true)
		MainGame.instance.dialogue_balloon.advance()
		MainGame.instance.dialogue_ui.hide_tutorial_rect()
		
	
	
func _on_submit_button_pressed() -> void:
	MainGame.instance.audio_manager.play_audio_by_id("article_submit", "SFX", 3.0)
	MainGame.instance.player_data.apply_changes_from_article(MainGame.instance.event_manager.article)
	MainGame.instance.event_manager.progress_event()

	
const ANIM_CLEAR_COLOR := Color(1,1,1,0)
const TITLE_ANIM_OFFSET := Vector2(0, -100)
const REAL_EVENT_ANIM_OFFSET := Vector2(-100, 0)
const DESIRED_PERCEPTION_ANIM_OFFSET := Vector2(100, 0)
const SUBMIT_ANIM_OFFSET := Vector2(100, 0)
const ANIM_IN_DURATION := 0.75
const ANIM_OUT_DURATION := 0.6
const SUBMIT_ANIM_IN_DURATION := 1.0
const SUBMIT_ANIM_OUT_DURATION := 0.8

var tween: Tween

func animate_in() -> void:
	setup(MainGame.instance.event_manager.article)

	spin_the_article_label.offset_transform_enabled = true
	spin_the_article_label.offset_transform_position = TITLE_ANIM_OFFSET
	spin_the_article_label.modulate = ANIM_CLEAR_COLOR

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
		
	await get_tree().process_frame

	if tween:
		tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT).set_parallel(true)
	
	tween.tween_property(spin_the_article_label, "offset_transform_position", Vector2.ZERO, ANIM_IN_DURATION)
	tween.tween_property(spin_the_article_label, "modulate", Color.WHITE, ANIM_IN_DURATION)
	
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
	if tween:
		tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT).set_parallel(true)
	
	tween.tween_property(spin_the_article_label, "offset_transform_position", TITLE_ANIM_OFFSET, ANIM_OUT_DURATION)
	tween.tween_property(spin_the_article_label, "modulate", ANIM_CLEAR_COLOR, ANIM_OUT_DURATION)
	
	tween.tween_property(real_event_panel, "offset_transform_position", REAL_EVENT_ANIM_OFFSET, ANIM_OUT_DURATION)
	tween.tween_property(real_event_panel, "modulate", ANIM_CLEAR_COLOR, ANIM_OUT_DURATION)
	
	tween.tween_property(desired_perception_ui, "offset_transform_position", DESIRED_PERCEPTION_ANIM_OFFSET, ANIM_OUT_DURATION)
	tween.tween_property(desired_perception_ui, "modulate", ANIM_CLEAR_COLOR, ANIM_OUT_DURATION)
	
	tween.tween_property(article_panel, "offset_transform_scale", Vector2.ZERO, ANIM_OUT_DURATION)
	tween.tween_property(article_panel, "modulate", ANIM_CLEAR_COLOR, ANIM_OUT_DURATION)
	
	tween.tween_property(submit_article_panel, "offset_transform_position", SUBMIT_ANIM_OFFSET, SUBMIT_ANIM_OUT_DURATION)
	tween.tween_property(submit_article_panel, "modulate", ANIM_CLEAR_COLOR, SUBMIT_ANIM_OUT_DURATION)
	
	set_dialogue_blocks_inputs(true)
	MainGame.instance.dialogue_layer.close()
	tutorial_state = ArticleUI.TutorialState.NONE
	MainGame.instance.dialogue_ui.hide_tutorial_rect()
	
	await tween.finished
