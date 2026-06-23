class_name TitleMenuUI
extends AnimatableControl


@export var player_data: PlayerData
@export var article_loader: ArticleLoader

@export var title_menu_layer: TransitionableLayer
@export var options_layer: TransitionableLayer
@export var credits_layer: TransitionableLayer
@export var article_layer: TransitionableLayer

@export var title_label: Control
@export var choices_container: Control
@export var continue_button: Control

func _on_new_pressed() -> void:
	print("new game pressed")
	player_data.start_new_save()
	# TODO: bring this to a new game dialogue or just straight to the map
	article_loader.load_test_article()
	title_menu_layer.transition_to(article_layer)
	pass
	
func _on_continue_pressed() -> void:
	print("continue pressed")
	pass

func _on_options_pressed() -> void:
	title_menu_layer.open_nested(options_layer)

func _on_credits_pressed() -> void:
	print("credits pressed")
	title_menu_layer.open_nested(credits_layer)
	
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
	await animate_controls(OUT_X, IN_X, OUT_MODULATE, IN_MODULATE, IN_DURATION, IN_CASCADE_DELAY, Tween.TRANS_BACK)

func animate_out():
	await animate_controls(IN_X, OUT_X, IN_MODULATE, OUT_MODULATE, OUT_DURATION, OUT_CASCADE_DELAY, Tween.TRANS_CUBIC)
	hide()
	
#func animate_in_quick():
	#animate_buttons(-400, 0, 0.3, 0)
	#
#func animate_out_quick():
	#animate_buttons(0, -400, 0.3, 0)

func animate_controls(start_x: float, end_x: float, start_modulate: Color, target_modulate: Color, duration: float, cascade_delay: float, trans: Tween.TransitionType) -> void:
	await get_tree().process_frame
	
	var controls := [title_label]
	controls.append_array(choices_container.get_children())
	
	for control: Control in controls:
		var start_pos = Vector2(start_x, control.position.y)
		control.position = start_pos
		control.modulate = start_modulate
	
	var current_duration := duration
	var tween = create_tween()
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
	continue_button.visible = player_data.save_started
