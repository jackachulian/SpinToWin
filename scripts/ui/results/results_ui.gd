class_name ResultsUI
extends AnimatableControl

@export var faction_container: Control

func _on_continue_button_pressed() -> void:
	# TODO: take player back to the map if the game is still going,
	# or this will probably be where any endings are played if the player won/lost
	MainGame.instance.city_map_layer.open_active()

func animate_in():
	show()
	for faction_index: int in faction_container.get_child_count():
		var faction_ui: FactionUI = faction_container.get_child(faction_index)
		faction_ui.modulate = Color(1,1,1,0)
		var old_rep: int = MainGame.instance.player_data.previous_reputations[faction_index]
		var new_rep: int = MainGame.instance.player_data.reputations[faction_index]
		faction_ui.setup(faction_index, old_rep, new_rep)
	
	for faction_index: int in faction_container.get_child_count():
		# skip showing Nellworian's Crown, for now
		if faction_index == 0: continue
		
		var faction_ui: FactionUI = faction_container.get_child(faction_index)
		animate_faction_ui_in(faction_ui)
		await get_tree().create_timer(0.25).timeout
		
func animate_out() -> void:
	for faction_index: int in faction_container.get_child_count():
		# skip animating Nellworian's Crown, for now
		if faction_index == 0: continue
		var faction_ui: FactionUI = faction_container.get_child(faction_index)
		faction_ui.animate_out()
		
func animate_faction_ui_in(faction_ui: FactionUI) -> void:
	faction_ui.animate_in()
	await get_tree().create_timer(0.4).timeout
	faction_ui.animate_rep_change()
