class_name CreditsUI
extends AnimatableControl

@export var credits_layer: TransitionableLayer

@export var credits_panel: Control

func _ready() -> void:
	credits_panel.scale = Vector2.ZERO

func _on_back_button_pressed() -> void:
	credits_layer.close()

func animate_in():
	var tween = create_tween()
	tween.tween_property(
		credits_panel, "scale", Vector2.ONE, 0.4
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func animate_out():
	var tween = create_tween()
	tween.tween_property(
		credits_panel, "scale", Vector2.ZERO, 0.3
	).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	await tween.finished
