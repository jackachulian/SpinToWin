class_name CityMapFactionPreview
extends Control

@export var faction_id: int

@export var base_container: MarginContainer
@export var expand_control: Control

@export var texture_rect: TextureRect
@export var progress_bar: ProgressBar

@export var hover_panel: PanelContainer
@export var name_label: Label
@export var desc_label: Label
#
#@export var unhovered_height: float = 68.0
#@export var hovered_height: float = 218.0

func _ready() -> void:
	hover_panel.self_modulate = Color(1,1,1,0)
	hover_panel.size.y = base_container.size.y
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	name_label.text = MainGame.instance.faction_data.names[faction_id]
	desc_label.text = MainGame.instance.faction_data.short_descriptions[faction_id]
	
var tween: Tween
func _on_mouse_entered() -> void:
	if tween: tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT).set_parallel()
	tween.tween_property(hover_panel, "self_modulate", Color.WHITE, 0.4)
	var hovered_height := base_container.size.y + expand_control.get_combined_minimum_size().y
	tween.tween_property(hover_panel, "size", Vector2(hover_panel.size.x, hovered_height), 0.4)
	
func _on_mouse_exited() -> void:
	if tween: tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT).set_parallel()
	tween.tween_property(hover_panel, "self_modulate", Color(1,1,1,0), 0.4)
	var unhovered_height := base_container.size.y
	tween.tween_property(hover_panel, "size", Vector2(hover_panel.size.x, unhovered_height), 0.4)
