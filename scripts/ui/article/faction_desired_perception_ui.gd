class_name FactionDesiredPerceptionUI
extends PanelContainer

@export var faction_id: int = 1

@export var texture_rect: TextureRect
@export var faction_name_label: Label
@export var desired_perception_label: Label
@onready var hover_panel: Panel = $HoverPanel

@export var normal_stylebox: StyleBox
@export var hovered_stylebox: StyleBox

signal clicked()

func _ready() -> void:
	hover_panel.add_theme_stylebox_override("panel", normal_stylebox)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func setup() -> void:
	var article := MainGame.instance.event_manager.article
	var desired_perception := article.desired_perceptions[faction_id]
	if desired_perception.is_empty():
		hide()
	else:
		show()
		if faction_id < MainGame.instance.faction_data.names.size():
			faction_name_label.text = MainGame.instance.faction_data.names[faction_id]
		elif faction_id == 4:
			faction_name_label.text = "Mr. Kraus"
		elif faction_id == 5:
			faction_name_label.text = "???"
		desired_perception_label.text = desired_perception

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			clicked.emit()
			
func _on_mouse_entered() -> void:
	hover_panel.add_theme_stylebox_override("panel", hovered_stylebox)
	
func _on_mouse_exited() -> void:
	hover_panel.add_theme_stylebox_override("panel", normal_stylebox)

func collapse() -> void:
	desired_perception_label.hide()
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	
func expand() -> void:
	desired_perception_label.show()
	size_flags_vertical = SIZE_EXPAND_FILL
