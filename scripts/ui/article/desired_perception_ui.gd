class_name DesiredPerceptionUI
extends Control

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
	for ui in faction_desired_perception_uis:
		if ui == clicked_ui:
			ui.expand()
		else:
			ui.collapse()

	
