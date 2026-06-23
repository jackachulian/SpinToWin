class_name ArticleChoiceUI
extends Control

@export var option_button: OptionButton

func setup(choice: ArticleChoice, font_size: int = 0) -> void:
	option_button.clear()
	
	if font_size > 0:
		option_button.add_theme_font_size_override("font_size", font_size)
	
	for choice_option_index: int in choice.options.size():
		var choice_option: ArticleChoiceOption = choice.options[choice_option_index]
		option_button.add_item(choice_option.text)
