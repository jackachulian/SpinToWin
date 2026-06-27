class_name MainGame
extends Node

static var instance: MainGame = MainGame.new()


## The layer to open when the game is started
@export var open_layer_on_start: TransitionableLayer

## The current active layer. There can be one active layer,
## and when a new active layer is opened, any current active layer is closed.
var active_layer: TransitionableLayer

var is_initialized: bool = false

## Called after ready initializations and reference sets are made
signal initialized()

func _enter_tree() -> void:
	instance = self

func _ready() -> void:
	faction_data = $Systems/FactionData
	if open_layer_on_start:
		transition_to(open_layer_on_start)
		
	is_initialized = true
	initialized.emit()
		
## Closes any active layer. 
## The passed layer becomes the new active layer and is opened.
func transition_to(trans_layer: TransitionableLayer) -> void:
	if active_layer == trans_layer:
		print(name, " is already open")
		return
	while active_layer and active_layer.animating:
		print("waiting for ",active_layer.name," to finish animating")
		await active_layer.animating_finished
	if active_layer: 
		active_layer.close()
	active_layer = trans_layer
	while active_layer.animating:
		print("waiting for ",active_layer.name," to finish animating")
		await active_layer.animating_finished
	active_layer.open()

# -------- Systems --------
@onready var player_data: PlayerData = $Systems/PlayerData
@onready var event_manager: EventManager = $Systems/EventManager
var faction_data: FactionData = FactionData.new()
@onready var dialogue_loader: DialogueLoader = $Systems/DialogueLoader
@onready var rain_manager: RainManager = $Systems/RainManager
@onready var audio_manager: AudioManager = $Systems/AudioManager

# -------- Canvas layers --------
@onready var core_layer: CanvasLayer = $CoreLayer
@onready var title_menu_layer: TransitionableLayer = $TitleMenuLayer
@onready var city_map_layer: TransitionableLayer = $CityMapLayer
@onready var article_layer: TransitionableLayer = $ArticleLayer
@onready var results_layer: TransitionableLayer = $ResultsLayer
@onready var dialogue_layer: TransitionableLayer = $DialogueLayer
@onready var options_layer: TransitionableLayer = $OptionsLayer
@onready var hud_layer: CanvasLayer = $HudLayer
@onready var credits_layer: TransitionableLayer = $CreditsLayer
@onready var transition_layer: CanvasLayer = $TransitionLayer
@onready var debug_layer: CanvasLayer = $DebugLayer

# -------- Misc --------
@onready var city_map_ui: CityMapUI = $CityMapLayer/CityMapUI
@onready var article_ui: ArticleUI = $ArticleLayer/ArticleUI
@onready var dialogue_ui: DialogueUI = $DialogueLayer/DialogueUI
@onready var dialogue_balloon: CustomDialogueBalloon = $DialogueLayer/DialogueUI/DialogueBalloon
@onready var hud_ui: HudUI = $HudLayer/HudUI
@onready var popup_ui: PopupUI = $HudLayer/HudUI/PopupUI
