class_name FactionUI
extends Control

@export var texture_rect: TextureRect
@export var faction_name_label: Label
@export var reputation_bar: ProgressBar

@export var rep_up_arrow: Polygon2D
@export var rep_down_arrow: Polygon2D


var GOOD_COLOR := Color(0.374, 0.64, 0.365, 1.0)
var AVERAGE_COLOR := Color(0.69, 0.576, 0.262, 1.0)
var BAD_COLOR := Color(0.7, 0.287, 0.224, 1.0)

## The ID of the faction this is displaying (see FACTION array on PlayerData).
var faction: int

## The reputation that should be shown as soon as this ui is set up
var old_reputation: float

## Reputation that was just recently set to. The UI will display this once
## animate_rep_change is called.
var new_reputation: float

# TODO: pass a faction data object or similar
func setup(faction: int, old_reputation: float, new_reputation: float) -> void:	
	self.faction = faction
	self.old_reputation = old_reputation
	self.new_reputation = new_reputation
	
	var color := get_reputation_color(old_reputation)
	reputation_bar.value = old_reputation
	var fill_stylebox: StyleBoxFlat = reputation_bar.get_theme_stylebox("fill")
	fill_stylebox.bg_color = color
	
	rep_up_arrow.hide()
	rep_down_arrow.hide()
	
func get_reputation_color(reputation: float) -> Color:
	if reputation < 50:
		return lerp(BAD_COLOR, AVERAGE_COLOR, clampf(remap(reputation, 10, 50, 0, 1), 0, 1))
	else:
		return lerp(AVERAGE_COLOR, GOOD_COLOR, clampf(remap(reputation, 50, 90, 0, 1), 0, 1))

const ANIM_OFFSET := Vector2(0.0, -100.0)

func animate_in() -> void:
	offset_transform_enabled = true
	offset_transform_position = ANIM_OFFSET
	
	var tween := create_tween()
	tween.tween_property(self, "offset_transform_position", Vector2.ZERO, 0.5).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "modulate", Color.WHITE, 0.4)
	await tween.finished

func animate_rep_change() -> void:
	var tween := create_tween()
	
	reputation_bar.value = old_reputation
	var value_change := new_reputation - old_reputation
	
	rep_up_arrow.hide()
	rep_down_arrow.hide()
	
	var anim_arrow: Node2D
	if value_change > 0:
		anim_arrow = rep_up_arrow
	else:
		anim_arrow = rep_down_arrow
		
	anim_arrow.show()
	anim_arrow.modulate = Color(1,1,1,0)
	anim_arrow.scale = Vector2.ZERO
	
	tween.tween_property(anim_arrow, "modulate", Color.WHITE, 0.5)
	tween.tween_property(anim_arrow, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BACK)
	
	tween.tween_property(reputation_bar, "value", new_reputation, 0.5).set_trans(Tween.TRANS_BACK)
	
	var new_rep_color := get_reputation_color(new_reputation)
	var fill_stylebox: StyleBoxFlat = reputation_bar.get_theme_stylebox("fill")
	tween.tween_property(fill_stylebox, "bg_color", new_rep_color, 0.5).set_trans(Tween.TRANS_BACK)
	
	await tween.finished

func animate_out() -> void:
	var tween := create_tween()
	tween.tween_property(self, "offset_transform_position", ANIM_OFFSET, 0.4)
	tween.tween_property(self, "modulate", Color(1,1,1,0), 0.4)
	await tween.finished
