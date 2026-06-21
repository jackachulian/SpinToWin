class_name MainGame
extends Node

# -------- Canvas layers --------
@onready var core_layer: CanvasLayer = $CoreLayer
@onready var article_layer: CanvasLayer = $ArticleLayer
@onready var dialogue_layer: DialogueManagerExampleBalloon = $DialogueLayer
@onready var pause_layer: CanvasLayer = $PauseLayer
@onready var transition_layer: CanvasLayer = $TransitionLayer
@onready var debug_layer: CanvasLayer = $DebugLayer
