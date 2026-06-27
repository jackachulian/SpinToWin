class_name DesiredPerceptionUI
extends Control

@export var article_ui: ArticleUI
@export var faction_desired_perception_uis: Array[FactionDesiredPerceptionUI]

func _ready() -> void:
	for ui in faction_desired_perception_uis:
		ui.clicked.connect(_on_faction_ui_clicked.bind(ui))

func setup() -> void:
	var first_shown: bool = false
	for ui in faction_desired_perception_uis:
		ui.setup()
		if ui.visible and not first_shown:
			ui.expand()
			first_shown = true
		else:
			ui.collapse()

func _on_faction_ui_clicked(clicked_ui: FactionDesiredPerceptionUI) -> void:
	MainGame.instance.audio_manager.play_audio_by_id("ui_expand")
	for ui in faction_desired_perception_uis:
		if ui == clicked_ui:
			ui.expand()
		else:
			ui.collapse()
			

	if article_ui.tutorial_state == ArticleUI.TutorialState.CLICK_DESIRED_PERCEPTIONS:
		article_ui.set_dialogue_blocks_inputs(true)
		MainGame.instance.dialogue_balloon.advance()
		MainGame.instance.dialogue_ui.hide_tutorial_rect()
		article_ui.tutorial_state = ArticleUI.TutorialState.NONE

	
