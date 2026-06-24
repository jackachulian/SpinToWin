class_name CityMapUI
extends AnimatableControl

@export var event_map_control: Control
@export var event_popups_control: Control

func _ready() -> void:
	await get_tree().process_frame
	for child: Node in event_map_control.get_children():
		if child is EventUI:
			# Make sure all popups appear in front of event icons / etc
			child.popup_panel.reparent(event_popups_control)
			child.popup_fit_control = event_popups_control
			
			#child.fit_popup_in_parent_global_rect()
			child.popup_shown.connect(_on_event_ui_popup_shown.bind(child))
			
func _on_event_ui_popup_shown(ui: EventUI) -> void:
	for child: Node in event_map_control.get_children():
		if child is EventUI:
			if child != ui:
				child.hide_popup()
