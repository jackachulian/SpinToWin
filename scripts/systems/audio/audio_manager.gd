class_name AudioManager
extends Node

@export var rain_ambience_asp: AudioStreamPlayer
@export var city_ambience_asp: AudioStreamPlayer

func _ready() -> void:
	fade_in([rain_ambience_asp, city_ambience_asp])

func fade_in(asps: Array[AudioStreamPlayer]) -> void:
	var tween = create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	
	for asp in asps:
		asp.volume_db = -80.0
		asp.play()
		tween.tween_property(asp, "volume_db", 0.0, 2.0)
	
