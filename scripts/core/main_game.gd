class_name MainGame
extends Node

# World roots
@onready var level_root_2d: Node2D = $World2D/LevelRoot
@onready var entity_root_2d: Node2D = $World2D/EntityRoot
@onready var effect_root_2d: Node2D = $World2D/EffectRoot

# UI roots
@onready var hud_root: Control = $HudLayer/HudRoot
@onready var pause_root: Control = $PauseLayer/PauseRoot
@onready var transition_root: Control = $TransitionLayer/TransitionRoot
@onready var debug_root: Control = $DebugLayer/DebugRoot
