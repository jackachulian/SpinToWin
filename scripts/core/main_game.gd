class_name MainGame
extends Node

## The layer to open when the game is started
@export var open_layer_on_start: TransitionableLayer

func _ready() -> void:
	if open_layer_on_start:
		open_layer_on_start.open()

# -------- Canvas layers --------
@onready var core_layer: CanvasLayer = $CoreLayer
@onready var title_menu_layer: TransitionableLayer = $TitleMenuLayer
@onready var article_layer: TransitionableLayer = $ArticleLayer
@onready var dialogue_layer: DialogueManagerExampleBalloon = $DialogueLayer
@onready var pause_layer: CanvasLayer = $PauseLayer
@onready var options_layer: TransitionableLayer = $OptionsLayer
@onready var transition_layer: CanvasLayer = $TransitionLayer
@onready var debug_layer: CanvasLayer = $DebugLayer
