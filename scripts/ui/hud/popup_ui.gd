class_name PopupUI
extends PanelContainer

@export var title_label: Label
@export var message_label: Label

@export var button_container: Control

## Index of the last option selected
var option_index: int

## Emitted when an option is selected
signal option_selected(index: int)

func show_popup(title: String, message: String, options: Array[String]) -> int:
	show()
	title_label.text = title
	message_label.text = message
	
	for child: Node in button_container.get_children():
		child.queue_free()
		
	for index: int in options.size():
		var button := Button.new()
		button_container.add_child(button)
		button.text = options[index]
		button.pressed.connect(_on_option_button_pressed.bind(index))
		
	await option_selected
	hide()
	return option_index
		
func _on_option_button_pressed(index: int) -> void:
	option_index = index
	option_selected.emit(index)
