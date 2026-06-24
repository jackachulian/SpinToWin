class_name EventUI
extends Control

@export var event_data: EventData

@export var start_time: int
@export var end_time: int

@export var icon_control: Control
@export var popup_panel: Control
@export var popup_y_offset: float = 16.0
@export var popup_linger_time: float = 0.5
@export var name_label: Label
@export var desc_label: Label

var icon_hovered: bool
var popup_hovered: bool
var icon_linger_timer: Timer
var popup_linger_timer: Timer

var popup_fit_control: Control

signal popup_shown()

func _ready() -> void:
	popup_panel.hide()
	icon_control.mouse_entered.connect(_on_icon_mouse_entered)
	icon_control.mouse_exited.connect(_on_icon_mouse_exited)
	popup_panel.mouse_entered.connect(_on_popup_mouse_entered)
	popup_panel.mouse_exited.connect(_on_popup_mouse_exited)
	
	name_label.text = event_data.event_name
	desc_label.text = event_data.event_description
	
	icon_linger_timer = Timer.new()
	icon_linger_timer.one_shot = true
	icon_linger_timer.wait_time = popup_linger_time
	add_child(icon_linger_timer)
	icon_linger_timer.timeout.connect(_on_icon_linger_timer_timeout)
	
	popup_linger_timer = Timer.new()
	popup_linger_timer.one_shot = true
	popup_linger_timer.wait_time = popup_linger_time
	add_child(popup_linger_timer)
	popup_linger_timer.timeout.connect(_on_popup_linger_timer_timeout)
	
func fit_popup_in_global_rect() -> void:
	var parent_global_rect := popup_fit_control.get_global_rect()
	popup_panel.size = Vector2.ZERO
	await get_tree().process_frame
	
	var event_center_x := global_position.x + size.x/2.0
	popup_panel.global_position.x = clamp(event_center_x - popup_panel.size.x/2.0, parent_global_rect.position.x, parent_global_rect.end.x - popup_panel.size.x)
	
	popup_panel.size = Vector2.ZERO
	var event_center_y := global_position.y + size.y / 2.0
	popup_panel.global_position.y = event_center_y - popup_y_offset - popup_panel.size.y
	var popup_global_rect := popup_panel.get_global_rect()
	if not parent_global_rect.encloses(popup_global_rect):
		popup_panel.global_position.y = event_center_y + popup_y_offset
		
	popup_panel.size = Vector2.ZERO
	
func _on_icon_mouse_entered() -> void:
	icon_hovered = true
	show_popup()
	if not icon_linger_timer.is_stopped():
		icon_linger_timer.stop()
	
func _on_icon_mouse_exited() -> void:
	print("icon linger timer started")
	icon_linger_timer.start()
	icon_hovered = false
	
func _on_popup_mouse_entered() -> void:
	popup_hovered = true
	if icon_hovered or not icon_linger_timer.is_stopped():
		show_popup()
	if not icon_linger_timer.is_stopped():
		icon_linger_timer.stop()
	if not popup_linger_timer.is_stopped():
		popup_linger_timer.stop()
	
func _on_popup_mouse_exited() -> void:
	print("popup linger timer started")
	popup_linger_timer.start()
	popup_hovered = false
	
func _on_icon_linger_timer_timeout() -> void:
	print("icon linger timer timeout")
	if not popup_hovered and popup_linger_timer.is_stopped():
		hide_popup()
	
func _on_popup_linger_timer_timeout() -> void:
	print("popup linger timer timeout")
	if not icon_hovered and icon_linger_timer.is_stopped():
		hide_popup()
	
func show_popup() -> void:
	popup_panel.show()
	if not popup_linger_timer.is_stopped():
		popup_linger_timer.stop()
	fit_popup_in_global_rect()
	popup_shown.emit()
		
func hide_popup() -> void:
	popup_panel.hide()
	
func _on_investigate_button_pressed() -> void:
	MainGame.instance.event_manager.play_event(event_data)
