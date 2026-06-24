class_name EventData
extends Resource

@export var event_name: String
@export var event_description: String

## Earliest act this event can spawn
@export var min_act: int
## Latest act this event can spawn
@export var max_act: int

## Earliest time of day this event can spawn (0=morning, 1=afternoon, 2=evening, 3=night)
@export var min_start_time: int
## Latest time of day this event can spawn (0=morning, 1=afternoon, 2=evening, 3=night)
@export var max_start_time: int

## Amount of time blocks this event lasts
@export var duration: int

## Location ID. No two events can occur at the same location ID at the same time
@export var location_id: int

## If true, this event is guaranteed to spawn and no other events can take its slot
## (This does not mean the player has to investigate it)
@export var guaranteed: bool

## If true, no other event will be scheduled at the same time as this event,
## and the player is required to investigate it
@export var exclusive: bool

## The act that this event was scheduled for by the event scheduler
var act: int

## The start time that this event was scheduled for by the event scheduler
var start_time: int


@export_file("*.dialogue") var start_dialogue_path: String
@export_file("*.txt") var article_file_path: String
@export_file("*.dialogue") var end_dialogue_path: String
