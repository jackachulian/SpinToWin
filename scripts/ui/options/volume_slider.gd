class_name VolumeSlider
extends HSlider

@export var audio_bus_name := "Master"

@onready var _bus := AudioServer.get_bus_index(audio_bus_name)

func _ready() -> void:
	AudioServer.set_bus_volume_db(_bus, linear_to_db(0.5))
	value = db_to_linear(AudioServer.get_bus_volume_db(_bus))
	value_changed.connect(_on_value_changed)

@warning_ignore("shadowed_variable_base_class")
func _on_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(_bus, linear_to_db(value))
	if audio_bus_name == "SFX":
		MainGame.instance.audio_manager.play_audio_by_id("ui_select")
