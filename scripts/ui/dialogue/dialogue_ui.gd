class_name DialogueUI
extends AnimatableControl

@export var dialogue_balloon: CustomDialogueBalloon

@export var dialogue_box: Control

const OUT_Y := 20
const IN_Y := 0
const OUT_MODULATE := Color(1,1,1,0)
const IN_MODULATE := Color(1,1,1,1)
const IN_DURATION := 0.5
const OUT_DURATION := 0.3

func _ready() -> void:
	dialogue_box.modulate = OUT_MODULATE

func animate_in():
	show()
	dialogue_balloon.balloon.show()
	dialogue_balloon.dialogue_label.self_modulate = Color.TRANSPARENT
	dialogue_balloon.character_label.self_modulate = Color.TRANSPARENT
	await animate_dialogue_box(OUT_Y, IN_Y, OUT_MODULATE, IN_MODULATE, IN_DURATION, Tween.TRANS_BACK)
	await get_tree().create_timer(0.2).timeout # Pause for effect
	dialogue_balloon.can_start = true

func animate_out():
	dialogue_balloon.can_start = false
	await animate_dialogue_box(IN_Y, OUT_Y, IN_MODULATE, OUT_MODULATE, OUT_DURATION, Tween.TRANS_CUBIC)
	hide()

func animate_dialogue_box(start_y: float, end_y: float, start_modulate: Color, target_modulate: Color, duration: float, trans: Tween.TransitionType) -> void:
	await get_tree().process_frame
	
	var pos_x := dialogue_box.position.x
	dialogue_box.position = Vector2(pos_x, start_y)
	dialogue_box.modulate = start_modulate
	
	var target_pos := Vector2(pos_x, end_y)
	var tween = create_tween()
	tween.set_trans(trans)
	tween.set_parallel(true)
	tween.tween_property(
		dialogue_box, "position", target_pos, duration
	).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(
		dialogue_box, "modulate", target_modulate, duration
	).set_ease(Tween.EASE_IN_OUT)
	
	await tween.finished
