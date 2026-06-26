class_name TitleMenuUI
extends AnimatableControl

@export var title_label: Control
@export var choices_container: Control
@export var continue_button: Control

@export_group("Debug Variables")
@export var override_continue: bool

func _on_new_pressed() -> void:
	print("new game pressed")
	MainGame.instance.player_data.start_new_save()
	MainGame.instance.player_data.open_layer_for_game_phase()
	pass
	
func _on_continue_pressed() -> void:
	print("continue pressed")
	#MainGame.instance.player_data.open_layer_for_game_phase()
	MainGame.instance.dialogue_layer.open_active()
	DialogueLoader.run_new_game_dialogue()
	
	

func _on_options_pressed() -> void:
	print("options pressed")
	MainGame.instance.title_menu_layer.open_nested(MainGame.instance.options_layer)

func _on_credits_pressed() -> void:
	print("credits pressed")
	MainGame.instance.title_menu_layer.open_nested(MainGame.instance.credits_layer)
	
func _on_quit_pressed() -> void:
	print("quit pressed")
	get_tree().quit()

const OUT_X := -50
const IN_X := 0
const OUT_MODULATE := Color(1,1,1,0)
const IN_MODULATE := Color(1,1,1,1)
const IN_DURATION := 0.6
const OUT_DURATION := 0.3
const IN_CASCADE_DELAY := 0.1
const OUT_CASCADE_DELAY := 0.0

func animate_in():
	show()
	check_continue()
	choices_container.get_child(0).call_deferred("grab_focus", true)
	await animate_controls(OUT_X, IN_X, OUT_MODULATE, IN_MODULATE, IN_DURATION, IN_CASCADE_DELAY, Tween.TRANS_BACK)

func animate_out():
	await animate_controls(IN_X, OUT_X, IN_MODULATE, OUT_MODULATE, OUT_DURATION, OUT_CASCADE_DELAY, Tween.TRANS_CUBIC)
	hide()
	
#func animate_in_quick():
	#animate_buttons(-400, 0, 0.3, 0)
	#
#func animate_out_quick():
	#animate_buttons(0, -400, 0.3, 0)

var tween: Tween
func animate_controls(start_x: float, end_x: float, start_modulate: Color, target_modulate: Color, duration: float, cascade_delay: float, trans: Tween.TransitionType) -> void:
	await get_tree().process_frame
	
	var controls := [title_label]
	controls.append_array(choices_container.get_children())
	
	for control: Control in controls:
		var start_pos = Vector2(start_x, control.position.y)
		control.position = start_pos
		control.modulate = start_modulate
	
	var current_duration := duration
	if tween: tween.kill()
	tween = create_tween()
	tween.set_trans(trans)
	tween.set_parallel(true)
	for control: Control in controls:
		var target_pos = Vector2(end_x, control.position.y)
		
		tween.tween_property(
			control, "position", target_pos, current_duration
		).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(
			control, "modulate", target_modulate, current_duration
		).set_ease(Tween.EASE_IN_OUT)
		
		current_duration += cascade_delay
			
	await tween.finished

func check_continue() -> void:
	if not override_continue:
		continue_button.visible = MainGame.instance.player_data.save_started if not override_continue else true
