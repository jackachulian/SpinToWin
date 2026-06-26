class_name AudioManager
extends Node

@export var rain_ambience_asp: AudioStreamPlayer
@export var city_ambience_asp: AudioStreamPlayer

@export var audio_stream_dict: Dictionary[StringName, AudioStream]

func _enter_tree() -> void:
	get_tree().node_added.connect(_on_tree_node_added)
	get_tree().node_removed.connect(_on_tree_node_removed)

func _ready() -> void:
	fade_in_asps([rain_ambience_asp, city_ambience_asp])

func play_audio_by_id(id: StringName, bus: StringName = &"SFX", volume_db: float = 0.0, pitch: float = 1.0, pitch_variance: float = 0.1) -> void:
	if not audio_stream_dict.has(id):
		push_error("No stream with id: ", id)
		return
	
	var temp_player = AudioStreamPlayer.new()
	add_child(temp_player)
	var stream := audio_stream_dict[id]
	temp_player.stream = stream
	temp_player.volume_db = volume_db
	temp_player.bus = bus
	temp_player.pitch_scale = pitch + randf_range(-1.0, 1.0)*pitch_variance
	temp_player.play()
	
	# Wait until the audio is completely done, then delete the player node
	await temp_player.finished
	temp_player.queue_free()

func fade_in_asps(asps: Array[AudioStreamPlayer]) -> void:
	var tween = create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	
	for asp in asps:
		asp.volume_db = -80.0
		asp.play()
		tween.tween_property(asp, "volume_db", -.0, 2.0)
	
func _on_tree_node_added(node: Node) -> void:
	# Connect to all buttons in the scene tree
	if node is BaseButton:
		# Connect both mouse hovering and keyboard/controller focus
		node.mouse_entered.connect(play_audio_by_id.bind("ui_select"))
		#node.focus_entered.connect(play_audio_by_id.bind("ui_select"))
		node.pressed.connect(play_audio_by_id.bind("ui_confirm"))

func _on_tree_node_removed(node: Node) -> void:
	# Disconnect to all buttons in the scene tree
	if node is BaseButton:
		# Connect both mouse hovering and keyboard/controller focus
		node.mouse_entered.disconnect(play_audio_by_id.bind("ui_select"))
		#node.focus_entered.disconnect(play_audio_by_id.bind("ui_select"))
		node.pressed.disconnect(play_audio_by_id.bind("ui_confirm"))
