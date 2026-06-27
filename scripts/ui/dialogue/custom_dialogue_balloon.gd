class_name CustomDialogueBalloon
extends Control

## The dialogue resource
@export var dialogue_resource: DialogueResource

## Start from a given title when using balloon as a [Node] in a scene.
@export var start_from_title: String = "start"

## If running as a [Node] in a scene then auto start the dialogue.
@export var auto_start: bool = false

## If all other input is blocked as long as dialogue is shown.
@export var will_block_other_input: bool = true

## The action to use for advancing the dialogue
@export var next_action: StringName = &"ui_accept"

## The action to use to skip typing the dialogue
@export var skip_action: StringName = &"ui_cancel"

## A sound player for voice lines (if they exist).
@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer

@onready var typing_audio_stream_player: AudioStreamPlayer = %TypingAudioStreamPlayer


@export_group("Speaker Colors")
## Maps a speaker string to a personal color
@export var known_speaker_colors: Dictionary[String, Color]

## The color for the Narration speaker
@export var narration_color: Color

## The default color for speakers
@export var default_speaker_color: Color

## Temporary game states
var temporary_game_states: Array = []

## See if we are waiting for the player
var is_waiting_for_input: bool = false

## See if we are running a long mutation and should hide the balloon
var will_hide_balloon: bool = false

## A dictionary to store any ephemeral variables
var locals: Dictionary = {}

var _locale: String = TranslationServer.get_locale()

## The current line
var dialogue_line: DialogueLine:
	set(value):
		if value:
			dialogue_line = value
			apply_dialogue_line()
		else:
			# The dialogue has finished so close the balloon
			if owner == null:
				queue_free()
			else:
				dialogue_end.emit()
	get:
		return dialogue_line

## A cooldown timer for delaying the balloon hide when encountering a mutation.
var mutation_cooldown: Timer = Timer.new()

## The base balloon anchor
@onready var balloon: Control = %Balloon

## The label showing the name of the currently speaking character
@onready var character_label: RichTextLabel = %CharacterLabel

## The label showing the currently spoken dialogue
@onready var dialogue_label: DialogueLabel = %DialogueLabel

## The menu of responses
@onready var responses_menu: CustomDialogueResponsesMenu = %ResponsesMenu

## Indicator to show that player can progress dialogue.
@onready var progress: Polygon2D = %Progress

## Only changed by DialogueUI
var can_start: bool = false:
	set(value):
		if value: can_start_now.emit()
		can_start = value

## If false, dialogue cannot advance to the next line via user input.
## (Is automatically set to true when a dialogue starts, can be set to false afterward)
var can_advance_via_input: bool = true

var type_sound_timer: float = 0.0

signal can_start_now

signal dialogue_end

func _ready() -> void:
	balloon.hide()
	Engine.get_singleton("DialogueManager").mutated.connect(_on_mutated)

	# If the responses menu doesn't have a next action set, use this one
	if responses_menu.next_action.is_empty():
		responses_menu.next_action = next_action

	mutation_cooldown.timeout.connect(_on_mutation_cooldown_timeout)
	add_child(mutation_cooldown)

	dialogue_end.connect(_on_dialogue_end)

	if auto_start:
		if not is_instance_valid(dialogue_resource):
			assert(false, DMConstants.get_error_message(DMConstants.ERR_MISSING_RESOURCE_FOR_AUTOSTART))
		start()
		
	dialogue_label.spoke.connect(_on_spoke)


func _process(delta: float) -> void:
	if is_instance_valid(dialogue_line):
		progress.visible = not dialogue_label.is_typing and dialogue_line.responses.size() == 0 and not dialogue_line.has_tag("voice") and can_advance_via_input
		
	type_sound_timer += delta


func _unhandled_input(_event: InputEvent) -> void:
	# Only the balloon is allowed to handle input while it's showing
	if will_block_other_input:
		get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	## Detect a change of locale and update the current dialogue line to show the new language
	if what == NOTIFICATION_TRANSLATION_CHANGED and _locale != TranslationServer.get_locale() and is_instance_valid(dialogue_label):
		_locale = TranslationServer.get_locale()
		var visible_ratio: float = dialogue_label.visible_ratio
		dialogue_line = await dialogue_resource.get_next_dialogue_line(dialogue_line.id)
		if visible_ratio < 1:
			dialogue_label.skip_typing()

const TYPE_SOUND_DELAY: float = 0.1
func _on_spoke(_letter: String, _letter_index: int, _speed: float) -> void:
	if type_sound_timer >= TYPE_SOUND_DELAY:
		MainGame.instance.audio_manager.play_audio_by_id("dialogue_type", "SFX", 0.0, 1.0, 0.2)
		## Interpolate time of next type sound with the timesince the last type sound.
		## Make sure the next type sound doesnt happen immediately if frame rate is inconsistent, claming the max timer to a fraction of delay
		type_sound_timer = minf(type_sound_timer - TYPE_SOUND_DELAY, TYPE_SOUND_DELAY*0.25)

## Queue up some dialogue to start when it can
func queue_start(with_dialogue_resource: DialogueResource = null, title: String = "start", extra_game_states: Array = []) -> void:
	can_advance_via_input = true
	if can_start:
		start(with_dialogue_resource, title, extra_game_states)
	else:
		await can_start_now
		can_start = false
		start(with_dialogue_resource, title, extra_game_states)

## Start some dialogue
func start(with_dialogue_resource: DialogueResource = null, title: String = "start", extra_game_states: Array = []) -> void:
	temporary_game_states = [self] + extra_game_states
	is_waiting_for_input = false
	if is_instance_valid(with_dialogue_resource):
		dialogue_resource = with_dialogue_resource
	if not title.is_empty():
		start_from_title = title
	balloon.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_INHERITED
	dialogue_label.self_modulate = Color.WHITE
	character_label.self_modulate = Color.WHITE
	dialogue_line = await dialogue_resource.get_next_dialogue_line(start_from_title, temporary_game_states)


## Apply any changes to the balloon given a new [DialogueLine].
func apply_dialogue_line() -> void:
	mutation_cooldown.stop()

	progress.hide()
	is_waiting_for_input = false
	balloon.focus_mode = Control.FOCUS_ALL
	balloon.grab_focus()

	character_label.modulate = known_speaker_colors.get(dialogue_line.character, default_speaker_color) if not dialogue_line.character.is_empty() else narration_color
	character_label.visible = not dialogue_line.character.is_empty()
	character_label.text = tr(dialogue_line.character if dialogue_line.character else "Narration", &"dialogue")

	dialogue_label.hide()
	dialogue_label.dialogue_line = dialogue_line

	responses_menu.responses = dialogue_line.responses

	# Show our balloon
	balloon.show()
	will_hide_balloon = false

	dialogue_label.show()
	if not dialogue_line.text.is_empty():
		dialogue_label.type_out()
		await dialogue_label.finished_typing

	# Wait for next line
	if dialogue_line.has_tag("voice"):
		audio_stream_player.stream = load(dialogue_line.get_tag_value("voice"))
		audio_stream_player.play()
		await audio_stream_player.finished
		next(dialogue_line.next_id)
	elif dialogue_line.responses.size() > 0:
		balloon.focus_mode = Control.FOCUS_NONE
		responses_menu.animate_in()
	elif dialogue_line.time != "":
		var time: float = dialogue_line.text.length() * 0.02 if dialogue_line.time == "auto" else dialogue_line.time.to_float()
		await get_tree().create_timer(time).timeout
		next(dialogue_line.next_id)
	else:
		is_waiting_for_input = true
		balloon.focus_mode = Control.FOCUS_ALL
		balloon.grab_focus()


## Go to the next line
func next(next_id: String) -> void:
	dialogue_line = await dialogue_resource.get_next_dialogue_line(next_id, temporary_game_states)


#region Signals


func _on_mutation_cooldown_timeout() -> void:
	if will_hide_balloon:
		will_hide_balloon = false
		dialogue_end.emit()


func _on_mutated(mutation: Dictionary) -> void:
	if not mutation.is_inline:
		is_waiting_for_input = false
		will_hide_balloon = true
		mutation_cooldown.start(0.1)


func _on_balloon_gui_input(event: InputEvent) -> void:
	if not can_advance_via_input: 
		return
	
	# See if we need to skip typing of the dialogue
	if dialogue_label.is_typing:
		var mouse_was_clicked: bool = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()
		var skip_button_was_pressed: bool = event.is_action_pressed(skip_action)
		if mouse_was_clicked or skip_button_was_pressed:
			get_viewport().set_input_as_handled()
			dialogue_label.skip_typing()
			return

	if not is_waiting_for_input: return
	if dialogue_line.responses.size() > 0: return

	# When there are no response options the balloon itself is the clickable thing
	get_viewport().set_input_as_handled()

	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		next(dialogue_line.next_id)
		
	elif event.is_action_pressed(next_action) and get_viewport().gui_get_focus_owner() == balloon:
		next(dialogue_line.next_id)

## Intended to be called from other scripts
func advance() -> void:
	next(dialogue_line.next_id)

func _on_responses_menu_response_selected(response: DialogueResponse) -> void:
	next(response.next_id)

func _on_dialogue_end() -> void:
	balloon.focus_mode = Control.FOCUS_NONE
	balloon.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_DISABLED
	responses_menu.animate_out()

#endregion
