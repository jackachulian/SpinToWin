# article_parser.gd
class_name ArticleParser

static func load_file(path: String) -> ArticleLevel:
	var text := FileAccess.get_file_as_string(path)
	return parse(text)

static func parse(text: String) -> ArticleLevel:
	var article := ArticleLevel.new()

	var current_section := ""

	for raw_line in text.split("\n"):
		var line := raw_line.strip_edges()

		if line.is_empty():
			continue

		if line.begins_with("#"):
			current_section = line
			continue

		match current_section:
			"#real-event":
				article.real_event += line + "\n"

			"#desired-perception":
				article.desired_perception += line + "\n"

			"#header":
				article.header = _parse_article_line(line)

			"#body":
				article.body.append(_parse_article_line(line))

	article.real_event = article.real_event.strip_edges()
	article.desired_perception = article.desired_perception.strip_edges()

	return article
	
static func _parse_article_line(text: String) -> ArticleLine:
	var result := ArticleLine.new()

	var regex := RegEx.new()
	regex.compile(r"\[(.*?)\]")

	var last_end := 0

	for match in regex.search_all(text):
		var start := match.get_start()
		var end := match.get_end()

		if start > last_end:
			result.parts.append(
				text.substr(last_end, start - last_end)
			)
			
		var choice_text := match.get_string(1)
		result.parts.append(
			_parse_choice(choice_text)
		)
		last_end = end

	if last_end < text.length():
		result.parts.append(
			text.substr(last_end)
		)

	return result
	
	
static func _parse_choice(text: String) -> ArticleChoice:
	var choice := ArticleChoice.new()

	var regex := RegEx.new()
	regex.compile(r"(.+?)\s*\((-?\d+),(-?\d+),(-?\d+)\)")

	for option_text in text.split("/"):
		option_text = option_text.strip_edges()

		var regex_match := regex.search(option_text)

		if regex_match == null:
			push_error("Invalid choice option: " + option_text)
			continue

		var option := ArticleChoiceOption.new()

		option.text = regex_match.get_string(1).strip_edges()

		option.government = regex_match.get_string(2).to_int()
		option.public_approval = regex_match.get_string(3).to_int()
		option.public_trust = regex_match.get_string(4).to_int()

		choice.options.append(option)

	return choice
