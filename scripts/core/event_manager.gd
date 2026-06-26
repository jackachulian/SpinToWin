## Holds information about the currently loaded event and article,
## and the choice option changes the player has made.
class_name EventManager
extends Node

## All events that are scheduled to happen at some point during the game
var event_schedule: Array[EventData]

## The event that is currently being played/investigated.
var event_data: EventData

enum EventPhase {
	START_DIALOGUE,
	ARTICLE_EDIT,
	RESULTS,
	END_DIALOGUE,
	ENDED
}

## Phase the current event is in
var event_phase: EventPhase

## The parsed article object that is currently being played/edited on the current event.
var article: ArticleLevel

## Play the event as the current active event.
## Will immediately progress to the first layer needed
## based on what the event contains. To progress further after any of those scenes are complete,
## call progress_event() on this event manager.
@warning_ignore("shadowed_variable")
func play_event(event_data: EventData) -> void:
	self.event_data = event_data
	event_phase = EventPhase.START_DIALOGUE
	open_layer_for_event_phase()

func progress_event() -> void:
	event_phase = (event_phase + 1) as EventPhase
	print("event phase=", event_phase)
	open_layer_for_event_phase()

## Move forward in an event's progression and transition to whatever
## current layer is needed
func open_layer_for_event_phase() -> void:		
	# Starting dialogue, if there is any
	if event_phase == EventPhase.START_DIALOGUE:
		if not event_data.start_dialogue_path.is_empty():
			print("playing start dialogue for event")
			var dialogue := ResourceLoader.load(event_data.start_dialogue_path)
			MainGame.instance.dialogue_layer.open_active()
			DialogueLoader.run_dialogue(dialogue)
		else:
			print("skipping start dialogue")
			progress_event()
		
	# Article edit, if there is an article
	elif event_phase == EventPhase.ARTICLE_EDIT:
		if not event_data.article_file_path.is_empty():
			print("opening article")
			load_and_set_active_article(event_data.article_file_path)
			MainGame.instance.article_layer.open_active()
		else:
			print("skipping article")
			progress_event()
	
	# Results, if there is an article
	elif event_phase == EventPhase.RESULTS:
		if not event_data.article_file_path.is_empty():
			print("showing results")
			MainGame.instance.results_layer.open_active()
		else:
			print("skipping results page")
			progress_event()
	
	# End dialogue, if there is any.
	# Otherwise, end the event here
	elif event_phase == EventPhase.END_DIALOGUE:
		if not event_data.end_dialogue_path.is_empty():
			print("playing end dialogue for event")
			var dialogue := ResourceLoader.load(event_data.end_dialogue_path)
			MainGame.instance.dialogue_layer.open_active()
			DialogueLoader.run_dialogue(dialogue)
		else:
			print("skipping event dialogue")
			progress_event()
			
	# End of event
	elif event_phase == EventPhase.ENDED:
		MainGame.instance.player_data.completed_events.append(event_data)
		event_data = null
		# will open the appropriate layer based on time
		print("event ended, advancing game phase")
		MainGame.instance.player_data.advance_game_phase()

## Load an article to be the main active article that will be edited by the ArticleLayer
## and its results shown on the ResultsLayer
@warning_ignore("shadowed_variable")
func set_active_article(article: ArticleLevel) -> void:
	self.article = article
	article.print_data()
	
func load_and_set_active_article(path: String) -> void:
	set_active_article(ArticleParser.load_file(path))
	
func get_test_article() -> ArticleLevel:
	return ArticleParser.load_file("res://assets/articles/tutorial_01.txt")
