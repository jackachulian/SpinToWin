extends Control

@export var foldable_container: FoldableContainer

func _ready() -> void:
	foldable_container.fold()

func _on_act_button_pressed(act: int, is_start: bool) -> void:
	var player_data := MainGame.instance.player_data
	player_data.start_new_save()
	player_data.act = act
	
	if is_start:
		player_data.time = 0
		player_data.game_phase = PlayerData.GamePhase.ACT_START_DIALOGUE
	else:
		player_data.time = 3
		player_data.game_phase = PlayerData.GamePhase.ACT_END_DIALOGUE
		
	player_data.open_layer_for_game_phase()
