# article_choice.gd
class_name ArticleChoice
extends RefCounted

## All options that can be chosen by the player
var options: Array[ArticleChoiceOption] = []

## Option currently selected that can be changed by the player
var chosen_option: int = 0
