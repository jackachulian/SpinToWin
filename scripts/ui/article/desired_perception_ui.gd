class_name DesiredPerceptionUI
extends Control

@export var article_ui: ArticleUI
@export var faction_desired_perception_uis: Array[FactionDesiredPerceptionUI]
@export var first_expanded_ui: FactionDesiredPerceptionUI

func _ready() -> void:
	for ui in faction_desired_perception_uis:
		ui.clicked.connect(_on_faction_ui_clicked.bind(ui))

func setup() -> void:
	for ui in faction_desired_perception_uis:
		ui.setup()
		if ui == first_expanded_ui:
			ui.expand()
		else:
			ui.collapse()

func _on_faction_ui_clicked(clicked_ui: FactionDesiredPerceptionUI) -> void:
	MainGame.instance.audio_manager.play_audio_by_id("ui_expand")
	for ui in faction_desired_perception_uis:
		if ui == clicked_ui:
			ui.expand()
		else:
			ui.collapse()
			
	if MainGame.instance.event_manager.event_data.is_tutorial:
		if article_ui.tutorial_state == ArticleUI.TutorialState.CLICK_DESIRED_PERCEPTIONS:
			MainGame.instance.dialogue_balloon.will_block_other_input = true
			MainGame.instance.dialogue_balloon.balloon.mouse_filter = Control.MOUSE_FILTER_STOP
			MainGame.instance.dialogue_balloon.can_advance_via_input = true
			MainGame.instance.dialogue_balloon.advance()
			article_ui.tutorial_state = ArticleUI.TutorialState.COMPLETED
			MainGame.instance.dialogue_ui.hide_tutorial_rect()

	
