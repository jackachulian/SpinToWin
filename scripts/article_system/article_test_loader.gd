class_name ArticleLoader
extends Node

@export var real_event_label: Label
@export var article_ui: ArticleUI
@export var desired_perception_label: Label

func _ready() -> void:
	var article := ArticleParser.load_file(
	    "res://assets/articles/tutorial_01.txt"
	)
	_print_article(article)
	
	real_event_label.text = article.real_event
	desired_perception_label.text = article.desired_perception
	article_ui.setup(article)
	
			
func _print_article(article: ArticleLevel):
	print(article.real_event)
	print(article.desired_perception)

	print("-------- #header --------")
	_print_article_line(article.header)
	print("")
	
	print("-------- #body --------")
	for line in article.body:
		_print_article_line(line)
		print("")
	
func _print_article_line(line: ArticleLine):
	for part in line.parts:
		if part is String:
			print("TEXT: ", part)

		elif part is ArticleChoice:
			print("CHOICE:")
			for option in part.options:
				print("\t%s (%d, %d, %d)" % [
					option.text,
					option.government,
					option.public_approval,
					option.public_trust
				])
