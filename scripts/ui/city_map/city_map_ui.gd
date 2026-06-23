class_name CityMapUI
extends AnimatableControl

@export var player_data: PlayerData
@export var article_loader: ArticleLoader

@export var results_layer: TransitionableLayer
@export var map_layer: TransitionableLayer

@export var faction_container: Control

func animate_in():
	for faction_index: int in faction_container.get_child_count():
		var faction_ui: FactionUI = faction_container.get_child(faction_index)
		faction_ui.modulate = Color(1,1,1,0)
		var old_rep: int = player_data.previous_reputations[faction_index]
		var new_rep: int = player_data.reputations[faction_index]
		faction_ui.setup(faction_index, old_rep, new_rep)
	
	for faction_index: int in faction_container.get_child_count():
		var faction_ui: FactionUI = faction_container.get_child(faction_index)
		faction_ui.show()
		animate_faction_ui(faction_ui)
		await get_tree().create_timer(0.25).timeout
		
func animate_faction_ui(faction_ui: FactionUI) -> void:
	faction_ui.animate_in()
	await get_tree().create_timer(0.4).timeout
	faction_ui.animate_rep_change()
