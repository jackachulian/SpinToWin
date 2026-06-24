## Holds information about the currently loaded event and article,
## and the choice option changes the player has made.
class_name EventManager
extends Node

## All events that are scheduled to happen at some point during the game
var event_schedule: Array[EventData]

## The event that is currently being played/investigated.
var event_data: EventData

enum EventPhase {
	STARTING,
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
func play_event(event_data: EventData) -> void:
	self.event_data = event_data
	event_phase = EventPhase.STARTING
	progress_event()

## Move forward in an event's progression and transition to whatever
## current layer is needed
func progress_event() -> void:	
	# Advance to the next phase
	event_phase = (event_phase + 1) as EventPhase
	
	# Starting dialogue, if there is any
	if event_phase == EventPhase.START_DIALOGUE:
		if not event_data.start_dialogue_path.is_empty():
			MainGame.instance.dialogue_layer.open_active()
			# TODO: play dialogue according to event_data.start_dialogue
		else:
			progress_event()
		
	# Article edit, if there is an article
	elif event_phase == EventPhase.ARTICLE_EDIT:
		if not event_data.article_file_path.is_empty():
			load_and_set_active_article(event_data.article_file_path)
			MainGame.instance.article_layer.open_active()
		else:
			progress_event()
	
	# Results, if there is an article
	elif event_phase == EventPhase.RESULTS:
		if not event_data.article_file_path.is_empty():
			MainGame.instance.results_layer.open_active()
		else:
			progress_event()
	
	# End dialogue, if there is any
	elif event_phase == EventPhase.END_DIALOGUE:
		if not event_data.end_dialogue_path.is_empty():
			MainGame.instance.dialogue_layer.open_active()
		else:
			progress_event()
			
	# End of event
	elif event_phase == EventPhase.ENDED:
		MainGame.instance.player_data.completed_events.append(event_data)
		event_data = null
		MainGame.instance.player_data.advance_time()
		

## Load an article to be the main active article that will be edited by the ArticleLayer
## and its results shown on the ResultsLayer
func set_active_article(article: ArticleLevel) -> void:
	self.article = article
	article.print_data()
	
func load_and_set_active_article(path: String) -> void:
	set_active_article(ArticleParser.load_file(path))
	
func get_test_article() -> ArticleLevel:
	return ArticleParser.load_file("res://assets/articles/tutorial_01.txt")
