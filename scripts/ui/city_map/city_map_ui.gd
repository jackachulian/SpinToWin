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
			
func animate_in():
	super.animate_in()
	update_event_visibility()
			
func update_event_visibility() -> void:
	var completed_events := MainGame.instance.player_data.completed_events
	for child: Node in event_map_control.get_children():
		if child is EventUI:
			child.visible = not child.event_data in completed_events
			
func _on_event_ui_popup_shown(ui: EventUI) -> void:
	for child: Node in event_map_control.get_children():
		if child is EventUI:
			if child != ui:
				child.hide_popup()
				
