class_name EventUI
extends Control

@export var event_data: EventData

@export var start_time: int
@export var end_time: int

@export var popup_info_hover_control: Control
@export var name_label: Label
@export var desc_label: Label

func _ready() -> void:
	pass
	
func _on_investigate_button_pressed() -> void:
	MainGame.instance.event_manager.play_event(event_data)
