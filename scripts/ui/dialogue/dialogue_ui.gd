class_name DialogueUI
extends AnimatableControl

@export var dialogue_balloon: CustomDialogueBalloon

@export var dialogue_box: Control

@onready var tutorial_focus_rect: Control = $TutorialFocusRect

const OUT_Y := 20
const IN_Y := 0
const OUT_MODULATE := Color(1,1,1,0)
const IN_MODULATE := Color(1,1,1,1)
const IN_DURATION := 0.5
const OUT_DURATION := 0.3

func _ready() -> void:
	hide_tutorial_rect()

func show_tutorial_focus_global_rect(global_rect: Rect2) -> void:
	tutorial_focus_rect.global_position = global_rect.position
	tutorial_focus_rect.size = global_rect.size
	tutorial_focus_rect.show()
	
func hide_tutorial_rect() -> void:
	tutorial_focus_rect.hide()

func _on_dialogue_ended() -> void:
	await get_tree().process_frame
	if MainGame.instance.active_layer == MainGame.instance.dialogue_layer:
		MainGame.instance.player_data.advance_game_phase()
	else:
		MainGame.instance.dialogue_layer.close()

func animate_in():
	show()
	dialogue_balloon.balloon.show()
	MainGame.instance.dialogue_loader.dialogue_end.connect(_on_dialogue_ended)
	dialogue_balloon.dialogue_label.self_modulate = Color.TRANSPARENT
	dialogue_balloon.character_label.self_modulate = Color.TRANSPARENT
	await animate_dialogue_box(OUT_Y, IN_Y, OUT_MODULATE, IN_MODULATE, IN_DURATION, Tween.TRANS_BACK)
	await get_tree().create_timer(0.2).timeout # Pause for effect
	dialogue_balloon.can_start = true

func animate_out():
	dialogue_balloon.can_start = false
	dialogue_balloon.responses_menu.animate_out()
	MainGame.instance.dialogue_loader.dialogue_end.disconnect(_on_dialogue_ended)
	await animate_dialogue_box(IN_Y, OUT_Y, IN_MODULATE, OUT_MODULATE, OUT_DURATION, Tween.TRANS_CUBIC)
	hide()

func animate_dialogue_box(start_y: float, end_y: float, start_modulate: Color, target_modulate: Color, duration: float, trans: Tween.TransitionType) -> void:
	
	var pos_x := dialogue_box.offset_transform_position.x
	dialogue_box.offset_transform_position = Vector2(pos_x, start_y)
	dialogue_box.modulate = start_modulate
	
	await get_tree().process_frame
	
	var target_pos := Vector2(pos_x, end_y)
	var tween = create_tween()
	tween.set_trans(trans)
	tween.set_parallel(true)
	tween.tween_property(
		dialogue_box, "offset_transform_position", target_pos, duration
	).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(
		dialogue_box, "modulate", target_modulate, duration
	).set_ease(Tween.EASE_IN_OUT)
	
	await tween.finished
