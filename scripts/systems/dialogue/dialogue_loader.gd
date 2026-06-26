class_name DialogueLoader
extends Node

@export_group("Quick Dialogues", "dialogue_")
@export var dialogue_new_game: DialogueResource

@export_subgroup("Tutorials", "dialogue_tutorial")
@export var dialogue_tutorial_1: DialogueResource
@export var dialogue_tutorial_2: DialogueResource

@export_subgroup("Act 1", "dialogue_a1_")
@export var dialogue_a1_day_end: DialogueResource

@export_subgroup("Act 2", "dialogue_a2_")
@export var dialogue_a2_day_start: DialogueResource
@export var dialogue_a2_day_end: DialogueResource

@export_subgroup("Act 3", "dialogue_a3_")
@export var dialogue_a3_day_start: DialogueResource
@export var dialogue_a3_day_end: DialogueResource


@export var balloon: CustomDialogueBalloon

signal dialogue_end()

func _ready() -> void:
	balloon.dialogue_end.connect(func(): dialogue_end.emit(); print("Dialogue Ended"))

#region Quicks

static func get_dialogue_loader() -> DialogueLoader:
	return MainGame.instance.dialogue_loader

static func run_dialogue(dialogue: DialogueResource) -> void:
	var dl = get_dialogue_loader()
	dl.start_dialogue(dialogue)

static func run_new_game_dialogue() -> void:
	var dl = get_dialogue_loader()
	dl.start_dialogue(dl.dialogue_new_game)

static func run_tutorial_dialogue() -> void:
	var dl = get_dialogue_loader()
	dl.start_dialogue(dl.dialogue_tutorial_1)

## [param act] determines which start of day dialogue plays
## an [param act] value of [code]1[/code] results in the new game dialogue playing
## returns true if a dialogue exists and was played
static func run_day_start_dialogue(act: int) -> bool:
	var dl = get_dialogue_loader()
	var dialogues: Array[DialogueResource] = [dl.dialogue_new_game, dl.dialogue_a2_day_start, dl.dialogue_a3_day_start]
	var dialogue := dialogues[act]
	if dialogue != null:
		dl.start_dialogue(dialogue)
		return true
	else:
		return false

## [param act] determines which end of day dialogue plays
static func run_day_end_dialogue(act: int) -> bool:
	var dl = get_dialogue_loader()
	var dialogues: Array[DialogueResource] = [dl.dialogue_a1_day_end, dl.dialogue_a2_day_end, dl.dialogue_a3_day_end]
	var dialogue := dialogues[act]
	if dialogue != null:
		dl.start_dialogue(dialogue)
		return true
	else:
		return false

#endregion

func start_dialogue(dialogue_to_start: DialogueResource) -> void:
	balloon.queue_start(dialogue_to_start, "start", [{"player_data" = MainGame.instance.player_data}])
