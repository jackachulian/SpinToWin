class_name ArticleUI
extends Control

@export var header_line_ui: ArticleLineUI
@export var body_vbox: VBoxContainer

@export var article_line_ui_scene: PackedScene

func setup(article: ArticleLevel) -> void:
	for child in body_vbox.get_children():
		child.queue_free()
		
	header_line_ui.setup(article.header)
		
	for line in article.body:
		var article_line_ui := article_line_ui_scene.instantiate() as ArticleLineUI
		body_vbox.add_child(article_line_ui)
		article_line_ui.setup(line)
		
