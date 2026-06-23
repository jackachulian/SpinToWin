class_name ArticleChoiceOptionItemUI
extends PanelContainer

@export var label: Label

var choice: ArticleChoice
var index: int

signal pressed

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			pressed.emit()

func setup(choice: ArticleChoice, index: int):
	self.index = index
	label.text = choice.options[index].text
