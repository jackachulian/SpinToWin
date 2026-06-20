# article_level.gd
class_name ArticleLevel
extends RefCounted

var real_event: String
var desired_perception: String
var header: ArticleLine
var body: Array[ArticleLine] = []
