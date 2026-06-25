class_name RainManager
extends Node

## If true, rain is currently playing
## This is used for when rain is already playing or if it needs to be started
var raining: bool = false

## If true, rain is allowed to randomly start and stop
## This is used by dialogue to prevent random raining/non-raining when not narratively happening
var random_raining: bool = false:
	set(value):
		var old_value := random_raining
		random_raining = value
		if value and not old_value:
			get_tree().create_timer(random_delay()).timeout.connect(catch_random_delay)
			print("Starting Random rain delay timer")

## If true, the scene is currently indoors
## This is used to apply EQ and effects for when indoors to sound muffled
var indoors: bool = false

## If true, the [RainManager] is currently transitioning between two states
var transitioning: bool = false

func _ready() -> void:
	random_raining = true

#region Modifiers
# These are functions with fragile signatures that inline dialogue (as well 
# as other places) uses.
# Dont change without also updating dialogue that uses them

## Disables random raining from running
func disable_random() -> void:
	random_raining = false
	print("Random raining has been disabled")

## Enables random raining
func enable_random() -> void:
	random_raining = true
	print("Random raining has been enabled")

## Starts raining if not already
func start_rain() -> void:
	if raining: return
	
	print("Raining has started")
	raining = true
	# TODO: Actually starting the rain, recommended to tween the volume for a
	# smooth face in

## Ends raining if not already
func end_rain() -> void:
	if not raining: return
	
	# TODO: Actually stopping the rain, recommended to tween the volume for a
	# smooth fade out
	raining = false
	print("Raining has ended")

## Muffles the rain if not already
func move_indoors() -> void:
	if indoors: return
	
	print("Raining is now indoors")
	indoors = true
	# TODO: Actually muffling the rain, recommended to tween

## Unmuffles the rain if not already
func move_outdoors() -> void:
	if not indoors: return
	
	# TODO: Actually unmuffling the rain, recommended to tween
	indoors = false
	print("Raining is now outdoors")

#endregion

#region Random Rain

const NONRUNNING_RAIN_TIMER_MIN: float = 20.0
const NONRUNNING_RAIN_TIMER_MAX: float = 30.0
const RUNNING_RAIN_TIMER_MIN: float = 35.0
const RUNNING_RAIN_TIMER_MAX: float = 60.0
const RANDOM_RAIN_DELAY_MIN: float = 0.0
const RANDOM_RAIN_DELAY_MAX: float = 8.0

## Short hand for picking a random value between min and max nonrunning timer
func random_nonrunning() -> float:
	return randf_range(NONRUNNING_RAIN_TIMER_MIN, NONRUNNING_RAIN_TIMER_MAX)

## Short hand for picking a random value between min and max running timer
func random_running() -> float:
	return randf_range(RUNNING_RAIN_TIMER_MIN, RUNNING_RAIN_TIMER_MAX)

## Short hand for picking a random value between min and max delay timer
func random_delay() -> float:
	return randf_range(RANDOM_RAIN_DELAY_MIN, RANDOM_RAIN_DELAY_MAX)

## Catches nonrunning rain timer
func catch_start_rain() -> void:
	if not random_raining: return
	start_rain()
	get_tree().create_timer(random_running()).timeout.connect(catch_end_rain)

## Catches running rain timer
func catch_end_rain() -> void:
	if not random_raining: return
	end_rain()
	get_tree().create_timer(random_nonrunning()).timeout.connect(catch_start_rain)

## Catches random activation delay timer
## Just randomly picks to declare a start or end of rain
func catch_random_delay() -> void:
	var rand := randi() % 2
	match rand:
		0:
			catch_start_rain()
		1:
			catch_end_rain()

#endregion
