class_name DialogueLoader
extends Node

@export_group("Quick Dialogues", "dialogue_")
@export var dialogue_new_game: DialogueResource

@export_subgroup("Act 1", "dialogue_a1_")
@export var dialogue_a1_day_end: DialogueResource

@export_subgroup("Act 2", "dialogue_a2_")
@export var dialogue_a2_day_start: DialogueResource
@export var dialogue_a2_day_end: DialogueResource

@export_subgroup("Act 3", "dialogue_a3_")
@export var dialogue_a3_day_start: DialogueResource
@export var dialogue_a3_day_end: DialogueResource

@export var balloon: CustomDialogueBalloon

signal dialogue_end

func _ready() -> void:
	balloon.dialogue_end.connect(func(): dialogue_end.emit(); print("Dialogue Ended"))

#region Quicks

static func get_dialogue_loader() -> DialogueLoader:
	return MainGame.instance.dialogue_loader

static func run_new_game_dialogue() -> void:
	var dl = get_dialogue_loader()
	dl.balloon.queue_start(dl.dialogue_new_game)

## [param act] determines which start of day dialogue plays
## an [param act] value of [code]1[/code] results in the new game dialogue playing
static func run_day_start_dialogue(act: int) -> void:
	var dl = get_dialogue_loader()
	match clampi(act, 1, 3):
		1:
			dl.balloon.queue_start(dl.dialogue_new_game)
		2:
			dl.balloon.queue_start(dl.dialogue_a2_day_start)
		3:
			dl.balloon.queue_start(dl.dialogue_a3_day_start)

## [param act] determines which end of day dialogue plays
static func run_day_end_dialogue(act: int) -> void:
	var dl = get_dialogue_loader()
	match clampi(act, 1, 3):
		1:
			dl.balloon.queue_start(dl.dialogue_a1_day_end)
		2:
			dl.balloon.queue_start(dl.dialogue_a2_day_end)
		3:
			dl.balloon.queue_start(dl.dialogue_a3_day_end)

#endregion

func start_dialogue(dialogue_to_start: DialogueResource) -> void:
	balloon.queue_start(dialogue_to_start)
