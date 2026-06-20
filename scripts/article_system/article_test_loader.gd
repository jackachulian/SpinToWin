class_name ArticleLoader
extends Node

@export var article_ui: ArticleUI

func _ready() -> void:
	var article := ArticleParser.load_file(
	    "res://assets/articles/tutorial_01.txt"
	)
	_print_article(article)
	
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
