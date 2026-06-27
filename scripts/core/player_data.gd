class_name PlayerData
extends Node

## When a save is loaded, this is true, otherwise, this is false
static var save_started: bool = false

enum GamePhase {
	ACT_START_TITLE_CARD, # shows a full screen title card for the act number and title
	ACT_START_DIALOGUE,
	CITY_MAP,
	EVENT, # will use the current event's EventPhase
	ACT_END_DIALOGUE,
	GAME_ENDED
}

var game_phase: GamePhase

## Current act (0-2 for act 1-3)
var act: int = 0

## Current time (0=afternoon, 1=evening, 2=night, 3=midnight)
var time: int = 0

## Indexes correspond to the FACTIONS array in FactionData
## Ranges from 0 to 100
var reputations: Array[int] = [50, 50, 50, 50]

## When an article is submitted, the current reputations are copied here
## before the new reputations are calculated.
## This data may be displayed on the results layer.
var previous_reputations: Array[int] = [0,0,0,0]

## Ranges from 0 to 100
var public_trust: int = 100

## When an article is submitted, the current trust is copied here
## before the new trust is calculated.
## This data may be displayed on the results layer.
var previous_public_trust: int

## Instances that the player told the truth when they could've told a lie
var truth_count: int

## Instances that the player told a lie
var lie_count: int

## List of events that have already been fully completed and cannot
## be encountered anymore
var completed_events: Array[EventData] = []

## If the player posted the truth of the conspiracy
var flags: Dictionary[String, bool] = {}

## When the current time block changes
signal time_changed()

## When any reputation with any faction changes
signal reputation_changed()

## When any flag's value is set
signal flag_changed()

func start_new_save(reset_properties: bool = true):
	save_started = true
	game_phase = GamePhase.ACT_START_TITLE_CARD
	
	# don't want to reset properties if via the debug menu,
	# where we want to have changed properties used in dialogue
	if reset_properties:
		reputations = [50, 50, 50, 50]
		public_trust = 100
		act = 0
		time = 0
		completed_events.clear()
		flags.clear()
	
	MainGame.instance.city_map_ui.schedule_all_events()

## Returns the id of the faction with the highest reputation
func get_highest_faction() -> int:
	var highest_faction = -1
	var highest_rep = -9999
	for faction_id in reputations.size():
		if reputations[faction_id] > highest_rep:
			highest_faction = faction_id
			highest_rep = reputations[faction_id]
	return highest_faction
	
## Get the reputation value of the highest reputation faction returned by get_highest_faction()
func get_highest_reputation() -> int:
	return reputations.max()

func get_faction_name(faction_id: int) -> String:
	return MainGame.instance.faction_data.names[faction_id]

func get_flag(id: String) -> bool:
	return flags.get(id, false)
	
func set_flag(id: String, value: bool) -> void:
	flags[id] = value
	print("set flag %s to %s" % [id, value])
	flag_changed.emit()

func get_truth_to_lie_ratio() -> float:
	if lie_count == 0: 
		return INF
	return (truth_count * 1.0) / lie_count

## Advance the state of the game and go to the appropriate layer.
func advance_game_phase() -> void:
	if not save_started:
		printerr("no save loaded, can't advance game phase")
		return
	
	# after the title card, advance to the act start dialogue
	if game_phase == GamePhase.ACT_START_TITLE_CARD:
		game_phase = GamePhase.ACT_START_DIALOGUE
			
	# after start dialogue, go to city map
	elif game_phase == GamePhase.ACT_START_DIALOGUE:
		game_phase = GamePhase.CITY_MAP
	
	# If in the city map phase,
	# moves time forward and open the appropriate layer
	# based on the time.
	elif game_phase == GamePhase.CITY_MAP:
		if MainGame.instance.event_manager.event_data != null:
			MainGame.instance.event_manager.progress_event()
			return
		
		if time >= 2:
			game_phase = GamePhase.ACT_END_DIALOGUE
		else:
			time += 1
			print("advanced time: act=%d, time=%d" % [act, time])
		time_changed.emit()
		
	# after the act end dialogue is complete, move to the next act,
	# or end the game if the last act was just ended
	elif game_phase == GamePhase.ACT_END_DIALOGUE:
		act += 1
		time = 0
		
		if act >= 3:
			print("game completed, going back to title and clearing save")
			game_phase = GamePhase.GAME_ENDED
		else:
			game_phase = GamePhase.ACT_START_TITLE_CARD
		
	print("advanced game: act=%d time=%d phase=%d " % [act, time, game_phase])
	## after the phase change / time change, open the appropriate layer
	open_layer_for_game_phase()
	
## Open the layer that corresponds with the current game state.
## Intended to be used when newgame/continue pressed and after the phase advances.
## May transition the game phase if there is nothing to show for the current game phase.
func open_layer_for_game_phase() -> void:
	match game_phase:
		GamePhase.ACT_START_TITLE_CARD:
			## TODO: open title card scene, and let that scene advance after it's done.
			## Advancing here for now
				advance_game_phase()
				
		GamePhase.ACT_START_DIALOGUE:
			var playing = DialogueLoader.run_day_start_dialogue(act)
			if playing:
				MainGame.instance.dialogue_layer.open_active()
			else:
				print("no start dialogue for act=", act, ", skipping to map")
				advance_game_phase()
				
		GamePhase.CITY_MAP:
			var playable_event_count := MainGame.instance.city_map_ui.get_playable_event_count()
			if playable_event_count > 0:
				MainGame.instance.city_map_layer.open_active()
			else:
				print("No events available right now, advancing game phase")
				MainGame.instance.player_data.advance_game_phase()
			
		GamePhase.EVENT:
			MainGame.instance.event_manager.open_layer_for_event_phase()
			
		GamePhase.ACT_END_DIALOGUE:
			var playing = DialogueLoader.run_day_end_dialogue(act)
			if playing:
				MainGame.instance.dialogue_layer.open_active()
			else:
				print("no end dialogue for act=", act, ", skipping")
				advance_game_phase()
			
		GamePhase.GAME_ENDED:
			save_started = false
			MainGame.instance.title_menu_layer.open_active()
	
func apply_changes_from_article(article: ArticleLevel):
	previous_reputations = reputations.duplicate()
	previous_public_trust = public_trust
	var changes := article.get_total_changes()
	for i in range(0,4):
		reputations[i] += changes[i]
	public_trust += changes[-3]
	truth_count += changes[-2]
	lie_count += changes[-1]
	reputation_changed.emit()
