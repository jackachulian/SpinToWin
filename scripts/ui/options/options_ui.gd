class_name OptionsUI
extends AnimatableControl

@export var options_layer: TransitionableLayer

@export var bg_darkener: Control
@export var options_panel: Control
@export var back_button: Control
@export var quit_to_title_button: Button

func _ready() -> void:
	options_panel.scale = Vector2.ZERO

func _on_back_button_pressed() -> void:
	options_layer.close()

func _on_quit_to_title_pressed() -> void:
	var option_index := await MainGame.instance.popup_ui.show_popup(
		"Quit Game",
		"Are you sure you want to quit? You will lose all your progress!",
		["Confirm", "Cancel"]
	)
	if option_index == 0:
		options_layer.close()
		MainGame.instance.player_data.save_started = false
		MainGame.instance.title_menu_layer.open_active()

func animate_in():
	quit_to_title_button.visible = MainGame.instance.player_data.save_started
	
	var tween = create_tween().set_parallel()
	tween.tween_property(
		options_panel, "scale", Vector2.ONE, 0.4
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(bg_darkener, "modulate", Color.WHITE, 0.3)
	await tween.finished
	back_button.call_deferred("grab_focus", true)

func animate_out():
	var tween = create_tween().set_parallel()
	tween.tween_property(
		options_panel, "scale", Vector2.ZERO, 0.3
	).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.tween_property(bg_darkener, "modulate", Color(1,1,1,0), 0.225)
	await tween.finished
