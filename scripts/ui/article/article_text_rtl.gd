class_name ArticleTextRTL
extends RichTextLabel

@export var article_ui: ArticleUI

var tooltip_panel: Control

## Meta tag the mouse is over
var hovered_meta: String = ""

## Meta tag of the choice currently being edited
var editing_meta: String = ""

var lines: Array[ArticleLine]

signal choice_clicked(choice: ArticleChoice, global_pos: Vector2, sentence_start: String)

func _ready() -> void:
	meta_clicked.connect(_on_meta_clicked)
	meta_hover_started.connect(_on_meta_hover_started)
	meta_hover_ended.connect(_on_meta_hover_ended)
	
func setup(lines: Array[ArticleLine]) -> void:
	self.lines = lines
	rebuild_text()
	
func rebuild_text() -> void:
	text = ""
	
	for line_index: int in lines.size():
		var line := lines[line_index]
		for part_index: int in line.parts.size():
			var part: Variant = line.parts[part_index]
			if part is String:
				text += part
			
			elif part is ArticleChoice:
				var meta := "%d/%d" % [line_index, part_index]
				var option_text: String = part.options[part.chosen_option].text
				if editing_meta == meta:
					text += "[color=#0000][u]%s[/u][/color]" % option_text
				elif hovered_meta == meta:
					text += "[url=%s][choice line=%d part=%d][bgcolor=black][color=white]%s[/color][/bgcolor][/choice][/url]" % [meta, line_index, part_index, option_text]
				else:
					text += "[url=%s][u]%s[/u][/url]" % [meta, option_text]
				
		text += " "
	
func _on_meta_clicked(meta: String):
	#print("Clicked: ", meta)
	editing_meta = meta
	
	var params := meta.split("/")
	var line_index := params[0].to_int()
	var part_index := params[1].to_int()
	var line: ArticleLine = lines[line_index]
	var choice: ArticleChoice = line.parts[part_index]
	
	var pos: Vector2 = ArticleChoiceTextEffect.positions[line_index][part_index]
	var global_pos := get_global_transform_with_canvas() * pos
	
	var sentence_start: String = ""
	part_index -= 1
	while part_index >= 0:
		var part = line.parts[part_index]
		if part is String:
			sentence_start = part + sentence_start
		else:
			break
			
		part_index -= 1
		#
	#if sentence_start.length() > 25:
		#sentence_start = "..."+sentence_start.right(25)
	#sentence_start += "______"
	
	choice_clicked.emit(choice, global_pos, sentence_start)
	rebuild_text()
	

func _on_meta_hover_started(meta):
	#print("Hovered: ", meta)
	hovered_meta = meta
	rebuild_text()

func _on_meta_hover_ended(meta):
	#print("Unhovered: ", meta)
	hovered_meta = ""
	rebuild_text()
	
## Called by ArticleUI when finished editing any choice
func reset_editing_text() -> void:
	editing_meta = ""
	rebuild_text()
