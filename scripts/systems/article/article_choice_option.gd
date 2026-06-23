# choice_option.gd
class_name ArticleChoiceOption
extends RefCounted

var text: String

## An array with the same length as the reputations array in PlayerData
## These will be added to the player's reputation if they 
## submit an article including this option
var reputation_changes: Array = [0,0,0,0]

## If this is negative, this option is a lie and will have different UI.
## (There will probably not be any options that increase public trust,
## but there will likely be lies that have more trust lowering than other lies)
var public_trust_change: int = 0
