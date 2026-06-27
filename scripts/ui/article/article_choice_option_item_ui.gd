class_name ArticleChoiceOptionItemUI
extends PanelContainer

@export var label: Label
@export var lie_control: Control

var choice: ArticleChoice
var index: int

signal pressed

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			pressed.emit()

@warning_ignore("shadowed_variable")
func setup(choice: ArticleChoice, index: int):
	self.choice = choice
	self.index = index
	label.text = choice.options[index].text
	lie_control.visible = choice.options[index].is_lie
