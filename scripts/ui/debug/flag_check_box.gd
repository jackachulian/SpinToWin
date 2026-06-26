extends CheckBox

@export var flag_id: String

func _ready() -> void:
	if MainGame.instance.is_initialized:
		_on_initialized()
	else:
		MainGame.instance.initialized.connect(_on_initialized)

func _on_initialized() -> void:
	_on_flag_changed()
	MainGame.instance.player_data.flag_changed.connect(_on_flag_changed)
	toggled.connect(_on_toggled)
	
func _on_flag_changed() -> void:
	button_pressed = MainGame.instance.player_data.get_flag(flag_id)
	
func _on_toggled(toggled_on: bool) -> void:
	MainGame.instance.player_data.set_flag(flag_id, toggled_on)
