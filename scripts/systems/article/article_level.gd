# article_level.gd
class_name ArticleLevel
extends RefCounted

## Shown on the event on the map when hovered over
var preview: String

var real_event: String

## One for each faction ID
var desired_perceptions: Array[String] = []

var header: ArticleLine

var body: Array[ArticleLine] = []

## Returns a list of changes if the article were to be submitted in its current state. The last item is Public Trurst change, all other items are reputation changes where their index corresponds to the FACTION array in PlayerData.
func get_total_changes() -> Array[int]:
	var reputation_changes: Array[int] = [0,0,0,0,0]
	_add_line_reputation_changes(reputation_changes, header)
	for line in body:
		_add_line_reputation_changes(reputation_changes, line)
	return reputation_changes

static func _add_line_reputation_changes(reputation_changes: Array[int], line: ArticleLine):
	for part in line.parts:
		if part is ArticleChoice:
			var option: ArticleChoiceOption = part.options[part.chosen_option]
			for i in range(0,4):
				reputation_changes[i] += option.reputation_changes[i]
			reputation_changes[4] += option.public_trust_change

func print_data():
	print(real_event)
	print(desired_perceptions)

	print("-------- #header --------")
	_print_article_line(header)
	print("")
	
	print("-------- #body --------")
	for line in body:
		_print_article_line(line)
		print("")
	
static func _print_article_line(line: ArticleLine):
	for part in line.parts:
		if part is String:
			print("TEXT: ", part)

		elif part is ArticleChoice:
			print("CHOICE:")
			for option: ArticleChoiceOption in part.options:
				print("\t%s (%s)" % [
					option.text,
					", ".join(option.reputation_changes)
				])
