extends HSlider

@export var faction_id: int

func _ready() -> void:
	if MainGame.instance.is_initialized:
		_on_initialized()
	else:
		MainGame.instance.initialized.connect(_on_initialized)
	
func _on_initialized() -> void:
	_on_reputation_changed()
	MainGame.instance.player_data.reputation_changed.connect(_on_reputation_changed)
	value_changed.connect(_on_value_changed)
	
func _on_reputation_changed() -> void:
	value = MainGame.instance.player_data.reputations[faction_id]
	
func _on_value_changed(new_value: float) -> void:
	print("set reputation of %d to %d" % [faction_id, new_value])
	MainGame.instance.player_data.reputations[faction_id] = int(new_value)
	MainGame.instance.player_data.reputation_changed.emit()
