@tool
class_name ArticleChoiceTextEffect
extends RichTextEffect

var bbcode: String = "choice"

## Dictionary. key = line index, value = Dictionary
## 		- key = part index: value = Vector2 of the first character of that tag
static var positions: Dictionary

func _process_custom_fx(char_data: CharFXTransform) -> bool:
	var line_index: int = char_data.env["line"]
	var part_index: int = char_data.env["part"]
	
	if char_data.relative_index == 0:
		var parts: Dictionary = positions.get_or_add(line_index, {})
		parts[part_index] = char_data.transform.get_origin()
		
	return true
