class_name PlayerData
extends Node

## When a save is loaded, this is true, otherwise, this is false
static var save_started: bool = false

## Current act (0-2 for act 1-3)
var act: int = 0

## Current time (0=afternoon, 1=evening, 2=night, 3=midnight)
var time: int = 0

## Indexes correspond to the FACTIONS array in FactionData
## Ranges from 0 to 100
var reputations: Array[int]

## When an article is submitted, the current reputations are copied here
## before the new reputations are calculated.
## This data may be displayed on the results layer.
var previous_reputations: Array[int]

## Ranges from 0 to 100
var public_trust: int

## When an article is submitted, the current trust is copied here
## before the new trust is calculated.
## This data may be displayed on the results layer.
var previous_public_trust: int

## List of events that have already been fully completed and cannot
## be encountered anymore
var completed_events: Array[EventData]

signal time_changed()

func start_new_save():
	save_started = true
	reputations = [50, 50, 50, 50]
	public_trust = 100
	
	MainGame.instance.city_map_ui.schedule_all_events()

func apply_changes_from_article(article: ArticleLevel):
	previous_reputations = reputations.duplicate()
	previous_public_trust = public_trust
	var changes := article.get_total_changes()
	for i in range(0,4):
		reputations[i] += changes[i]
	public_trust += changes[4]

func advance_time() -> void:
	time += 1
	if time >= 4:
		time = 0
		act += 1
	print("advanced time to: act=%d, time=%d" % [act, time])
	
	if act >= 2:
		# TODO: Do end game stuff / endings
		MainGame.instance.title_menu_layer.open_active()
		return
		
	time_changed.emit()
