class_name OptionsUI
extends AnimatableControl

@export var options_layer: TransitionableLayer

@export var options_panel: Control
@export var back_button: Control

func _ready() -> void:
	options_panel.scale = Vector2.ZERO

func _on_back_button_pressed() -> void:
	options_layer.close()


func animate_in():
	var tween = create_tween()
	tween.tween_property(
		options_panel, "scale", Vector2.ONE, 0.4
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await tween.finished
	back_button.call_deferred("grab_focus", true)

func animate_out():
	var tween = create_tween()
	tween.tween_property(
		options_panel, "scale", Vector2.ZERO, 0.3
	).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	await tween.finished
