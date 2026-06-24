class_name FactionData
extends Node

@export var icons: Array[Texture2D] = []

@export var names = [
	"The Nellworian Crown", 
	"The Consortium", 
	"The Laymen’s Syndicate", 
	"New Argentis City Government"
]

@export var short_descriptions = [
	"The Grand Duchy of Nellworia.",
	"The aristocratic barons of Old Saint’s District.",
	"The workers and laborers of New Argentis.",
	"The ones currently in power of the city.",
]

const GOOD_COLOR := Color(0.374, 0.64, 0.365, 1.0)
const AVERAGE_COLOR := Color(0.69, 0.576, 0.262, 1.0)
const BAD_COLOR := Color(0.7, 0.287, 0.224, 1.0)

static func get_reputation_color(reputation: float) -> Color:
	if reputation < 50:
		return lerp(BAD_COLOR, AVERAGE_COLOR, clampf(remap(reputation, 10, 50, 0, 1), 0, 1))
	else:
		return lerp(AVERAGE_COLOR, GOOD_COLOR, clampf(remap(reputation, 50, 90, 0, 1), 0, 1))
