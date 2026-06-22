## Holds information about the currently loaded article,
## and the choice option changes the player has made.
class_name ArticleLoader
extends Node

var article: ArticleLevel

func load_article(file_path: String) -> void:
	article = ArticleParser.load_file(file_path)
	print("loaded article: ", file_path)
	article.print_data()
	
func load_test_article() -> void:
	load_article("res://assets/articles/tutorial_01.txt")
