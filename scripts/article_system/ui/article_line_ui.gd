class_name ArticleLineUI
extends FlowContainer

@export var article_choice_ui_scene: PackedScene
@export var label_settings: LabelSettings
@export var font_size: int

func setup(line: ArticleLine):
	for child in get_children():
		child.queue_free()
	
	for part in line.parts:
		if part is String:
			var words: PackedStringArray = part.split(" ")
			for word in words:
				word.strip_edges()
				if word.is_empty():
					continue
				
				var text_label := Label.new()
				text_label.text = word
				if label_settings:
					text_label.label_settings = label_settings
				add_child(text_label)
		
		elif part is ArticleChoice:
			var article_choice_ui := article_choice_ui_scene.instantiate() as ArticleChoiceUI
			add_child(article_choice_ui)
			article_choice_ui.setup(part, font_size)
