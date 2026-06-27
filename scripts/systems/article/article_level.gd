# article_level.gd
class_name ArticleLevel
extends RefCounted

var real_event: String

## One for each faction ID
var desired_perceptions: Array[String] = []

var header: ArticleLine

var body: Array[ArticleLine] = []

## Returns a list of changes if the article were to be submitted in its current state. [-3] is Public Trurst change, all other items are reputation changes where their index corresponds to the FACTION array in PlayerData.
## [-2] is ttotal truths told where a lie could have been told, and [-1] is total lies told.
func get_total_changes() -> Array[int]:
	var reputation_changes: Array[int] = [0,0,0,0,0,0,0]
	_add_line_reputation_changes(reputation_changes, header)
	for line in body:
		_add_line_reputation_changes(reputation_changes, line)
	return reputation_changes

static func _add_line_reputation_changes(reputation_changes: Array[int], line: ArticleLine):
	for part in line.parts:
		if part is ArticleChoice:
			var could_lie: bool = false
			for opt: ArticleChoiceOption in part.options:
				if opt.is_lie:
					could_lie = true
			
			var option: ArticleChoiceOption = part.options[part.chosen_option]
			for i in range(0,4):
				reputation_changes[i] += option.reputation_changes[i]
				
			reputation_changes[-3] += option.public_trust_change
			if option.is_lie:
				reputation_changes[-2] += 1
			elif could_lie:
				reputation_changes[-1] += 1
				

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
