class_name CityMapUI
extends AnimatableControl

@export var event_map_control: Control
@export var event_popups_control: Control
@export var time_label: Label

func _ready() -> void:
	await get_tree().process_frame
	for child: Node in event_map_control.get_children():
		if child is EventUI:
			# Make sure all popups appear in front of event icons / etc
			child.popup_panel.reparent(event_popups_control)
			child.popup_fit_control = event_popups_control
			
			#child.fit_popup_in_parent_global_rect()
			child.popup_shown.connect(_on_event_ui_popup_shown.bind(child))

func animate_in():
	if not MainGame.instance.player_data.time_changed.is_connected(_on_time_changed):
		MainGame.instance.player_data.time_changed.connect(_on_time_changed)
		
	update_events()
	update_time_ui()
	
	modulate = Color(1,1,1,0)
	var tween = create_tween().set_parallel()
	tween.tween_property(
		self, "modulate", Color.WHITE, 0.8
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tween.finished

func animate_out():
	var tween = create_tween().set_parallel()
	tween.tween_property(
		self, "modulate", Color(1,1,1,0), 0.8
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tween.finished

func update_time_ui() -> void:
	var act := MainGame.instance.player_data.act
	var time := MainGame.instance.player_data.time
	var act_string = ["I", "II", "III"][act]
	var time_string = ["Afternoon", "Evening", "Midnight", "Witching Hour"][time]
	time_label.text = "Act %s - %s" % [act_string, time_string]
	
func update_events() -> void:
	for child: Node in event_map_control.get_children():
		if child is EventUI:
			var event_data: EventData = child.event_data
			child.visible = is_event_playable(event_data)
		
func get_playable_event_count() -> int:
	var playable_event_count: int = 0
	for child: Node in event_map_control.get_children():
		if child is EventUI:
			var event_data: EventData = child.event_data
			if is_event_playable(event_data):
				playable_event_count += 1
				
	return playable_event_count
	
func get_playable_events() -> Array[EventData]:
	var playable_events: Array[EventData] = []
	for child: Node in event_map_control.get_children():
		if child is EventUI:
			var event_data: EventData = child.event_data
			if is_event_playable(event_data):
				playable_events.append(event_data)
				
	return playable_events
	
static func is_event_playable(event_data: EventData) -> bool:
	var act := MainGame.instance.player_data.act
	var time := MainGame.instance.player_data.time
	return (
		event_data.act == act
		and event_data.start_time >= time
		and event_data.start_time + event_data.duration - 1 <= time
	)
			
func _on_event_ui_popup_shown(ui: EventUI) -> void:
	for child: Node in event_map_control.get_children():
		if child is EventUI:
			if child != ui:
				child.hide_popup()
	
func _on_time_changed() -> void:
	update_time_ui()	
	update_events()
			
func schedule_all_events() -> void:
	## All exclusive events
	var exclusive_events: Array[EventData] = []
	## All guaranteed events that are not exclusive
	var guaranteed_events: Array[EventData] = []
	## All events that are not guaranteed or exclusive
	var normal_events: Array[EventData] = []
	
	## All scheduled events
	var event_schedule: Array[EventData] = []
	
	for child: Node in event_map_control.get_children():
		if child is EventUI:
			var event_data: EventData = child.event_data
			if event_data.exclusive:
				exclusive_events.append(event_data)
			elif event_data.guaranteed:
				guaranteed_events.append(event_data)
			else:
				normal_events.append(event_data)
			
	# Schedule all exclusive events first
	for event in exclusive_events:
		try_schedule_event(event_schedule, event)
	# Then guaranteed events
	for event in guaranteed_events:
		try_schedule_event(event_schedule, event)
	# Then normal events
	for event in normal_events:
		try_schedule_event(event_schedule, event)
				
	print("scheduled %d events" % event_schedule.size())
	MainGame.instance.event_manager.event_schedule = event_schedule
				
func try_schedule_event(schedule: Array[EventData], event_data: EventData) -> bool:
	var acts := range(event_data.min_act, event_data.max_act+1)
	acts.shuffle()
	for act in acts:
		var times := range(event_data.min_start_time, event_data.max_start_time+1)
		times.shuffle()
		for time in times:
			var valid_time: bool = true
			for other_event_data in schedule:
				var at_same_time: bool = (time <= other_event_data.start_time + other_event_data.duration-1
				and time + event_data.duration-1 <= other_event_data.start_time)
				
				# An event cannot be at the same time and at the same place as another event
				if at_same_time and event_data.location_id == other_event_data.location_id:
					valid_time = false
					break
				# Cannot be at the same time as another exclusive event,
				# no matter where it is taking place
				if at_same_time and other_event_data.exclusive:
					valid_time = false
					break
					
			if not valid_time:
				continue
					
			event_data.act = act
			event_data.start_time = time
			schedule.append(event_data)
			print("event %s scheduled for: act %d, time=%d" % [event_data, act, time])
			return true

	if event_data.guaranteed or event_data.exclusive:
		push_error("Failed to schedule guaranteed/exclusive event: ", event_data)
	else:
		print("Skipped scheduling optional event: ", event_data)
	return false
