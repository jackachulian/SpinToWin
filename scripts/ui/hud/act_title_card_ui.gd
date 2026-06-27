class_name ActTitleCardUI
extends ColorRect

@onready var title_label: Label = $TitleLabel
@onready var subtitle_label: Label = $SubtitleLabel
@onready var projector_ambience: AudioStreamPlayer = $ProjectorAmbience

func _ready() -> void:
	hide()

func animate_title_card(title_text: String, subtitle_text: String) -> void:
	title_label.text = title_text
	title_label.hide()
	subtitle_label.text = subtitle_text
	subtitle_label.hide()
	projector_ambience.volume_db = 0.0
	
	show()
	
	MainGame.instance.audio_manager.fade_out_ambience()
	var tween := create_tween()
	tween.set_parallel(false)
	modulate = Color(1,1,1,0)
	tween.tween_property(self, "modulate", Color.WHITE, 1.0)
	tween.tween_callback(projector_ambience.play)
	tween.tween_interval(1.0)
	tween.tween_callback(title_label.show)
	tween.tween_interval(2.0)
	tween.tween_callback(subtitle_label.show)
	tween.tween_interval(3.0)

	tween.tween_property(self, "modulate", Color(1,1,1,0), 1.0)
	tween.set_parallel(true)
	tween.tween_property(projector_ambience, "volume_db", -80.0, 1.0)
	tween.tween_callback(MainGame.instance.audio_manager.fade_in_ambience)
	
	await tween.finished
	
	projector_ambience.stop()
	hide()
